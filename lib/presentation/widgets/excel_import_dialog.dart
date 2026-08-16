import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/excel_service.dart';
import '../../data/repositories/onu_repository.dart';
import '../../domain/models/user_model.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);

class ExcelImportDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const ExcelImportDialog({super.key, required this.user});

  @override
  ConsumerState<ExcelImportDialog> createState() => _ExcelImportDialogState();
}

class _ExcelImportDialogState extends ConsumerState<ExcelImportDialog> {
  final _excelService = ExcelService();
  final _onuRepository = OnuRepository();

  Uint8List? _fileBytes;
  String? _fileName;
  ExcelValidationResult? _validationResult;
  ExcelParseResult? _parseResult;
  bool _isLoading = false;
  bool _isImporting = false;
  ImportResult? _importResult;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _fileBytes = file.bytes;
          _fileName = file.name;
          _validationResult = null;
          _parseResult = null;
          _importResult = null;
          _errorMessage = null;
          _isLoading = true;
        });

        await _validateAndParse();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al seleccionar archivo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _validateAndParse() async {
    if (_fileBytes == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final validation = _excelService.validateStructure(_fileBytes!);
      setState(() {
        _validationResult = validation;
      });

      if (validation.isValid) {
        final parseResult = _excelService.parseExcel(_fileBytes!);
        setState(() {
          _parseResult = parseResult;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al procesar archivo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _importData() async {
    if (_parseResult == null || _parseResult!.validRecords.isEmpty) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final result = await _onuRepository.importOnusFromExcel(
        _parseResult!.validRecords,
        widget.user,
      );

      setState(() {
        _importResult = result;
        _isImporting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error durante la importación: $e';
        _isImporting = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _fileBytes = null;
      _fileName = null;
      _validationResult = null;
      _parseResult = null;
      _importResult = null;
      _errorMessage = null;
      _isLoading = false;
      _isImporting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _N,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Importar Excel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(_importResult != null),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(),
              ),
            ),
            if (_buildActions().isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildActions(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_importResult != null) {
      return _buildResultView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_validationResult != null && !_validationResult!.isValid) {
      return _buildValidationError();
    }

    if (_parseResult != null) {
      return _buildPreview();
    }

    return _buildFileSelector();
  }

  Widget _buildFileSelector() {
    return Column(
      children: [
        const Icon(Icons.cloud_upload_outlined, size: 64, color: _O),
        const SizedBox(height: 16),
        const Text(
          'Selecciona un archivo Excel (.xlsx)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        const Text(
          'El archivo debe contener las columnas requeridas para los registros de ONUs.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.folder_open),
          label: const Text('Seleccionar Archivo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _O,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        _buildRequiredColumnsInfo(),
      ],
    );
  }

  Widget _buildRequiredColumnsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Columnas Requeridas:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ExcelService.requiredColumns.map((col) {
              return Chip(
                label: Text(col, style: const TextStyle(fontSize: 11)),
                backgroundColor: _O.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: _N),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Column(
      children: [
        CircularProgressIndicator(color: _O),
        SizedBox(height: 16),
        Text('Validando archivo...'),
      ],
    );
  }

  Widget _buildValidationError() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        const Text(
          'Estructura de archivo inválida',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 8),
        Text(_validationResult!.errorMessage ?? 'Error desconocido'),
        if (_validationResult!.missingColumns.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Columnas faltantes:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _validationResult!.missingColumns.map((col) {
              return Chip(
                label: Text(col, style: const TextStyle(fontSize: 11)),
                backgroundColor: Colors.red.shade50,
                labelStyle: TextStyle(color: Colors.red.shade700),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Intentar de Nuevo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _O,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final records = _parseResult!.validRecords;
    final errors = _parseResult!.errors;
    final previewCount = records.length > 5 ? 5 : records.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Text(
              'Archivo válido: $_fileName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              'Total Filas',
              '${_parseResult!.totalRows}',
              Icons.table_rows,
              _N,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Registros Válidos',
              '${records.length}',
              Icons.check_circle_outline,
              Colors.green,
            ),
            if (errors.isNotEmpty) ...[
              const SizedBox(width: 12),
              _buildStatCard(
                'Con Errores',
                '${errors.length}',
                Icons.warning_amber,
                Colors.orange,
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Vista Previa (primeros 5 registros):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              columns: const [
                DataColumn(label: Text('MAC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Serial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Localidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: records.take(previewCount).map((onu) {
                return DataRow(cells: [
                  DataCell(Text(onu.mac, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(onu.numeroSerial, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(onu.clienteNombre, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(onu.localidad, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(onu.estado, style: const TextStyle(fontSize: 12))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Intentar de Nuevo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _O,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final result = _importResult!;
    final isSuccess = result.errorCount == 0;

    return Column(
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.warning_amber,
          size: 64,
          color: isSuccess ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 16),
        Text(
          isSuccess ? 'Importación Exitosa' : 'Importación Completada con Errores',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isSuccess ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard(
              'Importados',
              '${result.successCount}',
              Icons.check_circle,
              Colors.green,
            ),
            if (result.errorCount > 0) ...[
              const SizedBox(width: 16),
              _buildStatCard(
                'Fallidos',
                '${result.errorCount}',
                Icons.error_outline,
                Colors.red,
              ),
            ],
          ],
        ),
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Errores:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.errors.take(5).map((error) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $error', style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
          ),
          if (result.errors.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '... y ${result.errors.length - 5} errores más',
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_importResult != null) {
      return [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _O,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cerrar'),
        ),
      ];
    }

    if (_parseResult != null && _parseResult!.validRecords.isNotEmpty && !_isImporting) {
      return [
        TextButton(
          onPressed: _reset,
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _importData,
          icon: const Icon(Icons.upload),
          label: Text('Importar ${_parseResult!.validRecords.length} Registros'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _O,
            foregroundColor: Colors.white,
          ),
        ),
      ];
    }

    if (_isImporting) {
      return [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _O),
            ),
            SizedBox(width: 12),
            Text('Importando...'),
          ],
        ),
      ];
    }

    return [];
  }
}
