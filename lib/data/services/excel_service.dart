import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../../domain/models/onu_model.dart';

class ExcelValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> missingColumns;
  final List<String> extraColumns;

  ExcelValidationResult({
    required this.isValid,
    this.errorMessage,
    this.missingColumns = const [],
    this.extraColumns = const [],
  });
}

class ExcelParseResult {
  final List<OnuModel> validRecords;
  final List<ExcelRowError> errors;
  final int totalRows;

  ExcelParseResult({
    required this.validRecords,
    required this.errors,
    required this.totalRows,
  });
}

class ExcelRowError {
  final int rowNumber;
  final String errorMessage;

  ExcelRowError({required this.rowNumber, required this.errorMessage});
}

class ExcelService {
  static const List<String> requiredColumns = [
    'numero_serial',
    'mac',
    'ssid',
    'password',
    'cliente_nombre',
    'localidad',
    'nap',
    'etiqueta',
    'modelo_ont',
    'tx',
    'rx',
    'tipo_instalacion',
    'estado',
    'tecnico_instalador',
    'soporte_provision',
  ];

  static const List<String> optionalColumns = [
    'id',
    'password_antigua',
  ];

  static const List<String> validEstados = [
    'Libre',
    'Ocupada',
    'Defectuosa',
  ];

  static const List<String> validTiposInstalacion = [
    'N/A',
    'Nuevo',
    'Cambio de ONT',
    'Cambio a fibra',
  ];

  ExcelValidationResult validateStructure(Uint8List fileBytes) {
    try {
      final excel = Excel.decodeBytes(fileBytes);
      if (excel.tables.isEmpty) {
        return ExcelValidationResult(
          isValid: false,
          errorMessage: 'El archivo Excel no contiene hojas de cálculo.',
        );
      }

      final sheet = excel.tables.values.first;
      if (sheet.rows.isEmpty) {
        return ExcelValidationResult(
          isValid: false,
          errorMessage: 'La hoja de cálculo está vacía.',
        );
      }

      final headerRow = sheet.rows.first;
      final headers = headerRow
          .map((cell) => cell?.value?.toString().toLowerCase().trim() ?? '')
          .where((h) => h.isNotEmpty)
          .toList();

      final missingColumns = <String>[];
      for (final col in requiredColumns) {
        if (!headers.contains(col)) {
          missingColumns.add(col);
        }
      }

      if (missingColumns.isNotEmpty) {
        return ExcelValidationResult(
          isValid: false,
          errorMessage: 'Faltan columnas requeridas.',
          missingColumns: missingColumns,
        );
      }

      return ExcelValidationResult(isValid: true);
    } catch (e) {
      return ExcelValidationResult(
        isValid: false,
        errorMessage: 'Error al leer el archivo Excel: $e',
      );
    }
  }

  ExcelParseResult parseExcel(Uint8List fileBytes) {
    final validRecords = <OnuModel>[];
    final errors = <ExcelRowError>[];

    try {
      final excel = Excel.decodeBytes(fileBytes);
      final sheet = excel.tables.values.first;
      final rows = sheet.rows;

      if (rows.isEmpty) {
        return ExcelParseResult(
          validRecords: [],
          errors: [ExcelRowError(rowNumber: 0, errorMessage: 'El archivo está vacío.')],
          totalRows: 0,
        );
      }

      final headerRow = rows.first;
      final headerMap = <String, int>{};
      for (int i = 0; i < headerRow.length; i++) {
        final header = headerRow[i]?.value?.toString().toLowerCase().trim() ?? '';
        if (header.isNotEmpty) {
          headerMap[header] = i;
        }
      }

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final rowNumber = i + 1;

        if (row.every((cell) => cell?.value == null || cell!.value.toString().trim().isEmpty)) {
          continue;
        }

        try {
          String getCell(String col) {
            final idx = headerMap[col];
            if (idx == null || idx >= row.length) return 'N/A';
            final value = row[idx]?.value?.toString().trim() ?? '';
            return value.isEmpty ? 'N/A' : value;
          }

          String getCellOptional(String col) {
            final idx = headerMap[col];
            if (idx == null || idx >= row.length) return '';
            return row[idx]?.value?.toString().trim() ?? '';
          }

          double parseDouble(String col) {
            final value = getCellOptional(col);
            if (value.isEmpty) return 0.0;
            final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
            if (match != null) return double.parse(match.group(0)!);
            return 0.0;
          }

          final estadoRaw = getCellOptional('estado');
          final estadoValido = estadoRaw.isNotEmpty && validEstados.contains(estadoRaw) 
              ? estadoRaw 
              : 'Libre';

          final tipoInstRaw = getCellOptional('tipo_instalacion');
          final tipoInstValido = tipoInstRaw.isNotEmpty && validTiposInstalacion.contains(tipoInstRaw) 
              ? tipoInstRaw 
              : 'N/A';

          final onu = OnuModel(
            id: getCellOptional('id').isNotEmpty ? getCellOptional('id') : null,
            numeroSerial: getCell('numero_serial'),
            mac: getCell('mac'),
            ssid: getCell('ssid'),
            password: getCell('password'),
            passwordAntigua: getCellOptional('password_antigua').isNotEmpty ? getCellOptional('password_antigua') : null,
            clienteNombre: getCell('cliente_nombre'),
            localidad: getCell('localidad'),
            nap: getCell('nap'),
            etiqueta: getCell('etiqueta'),
            modeloOnt: getCell('modelo_ont'),
            tx: parseDouble('tx'),
            rx: parseDouble('rx'),
            tipoInstalacion: tipoInstValido,
            estado: estadoValido,
            tecnicoInstalador: getCell('tecnico_instalador'),
            soporteProvision: getCell('soporte_provision'),
          );

          validRecords.add(onu);
        } catch (e) {
          errors.add(ExcelRowError(
            rowNumber: rowNumber,
            errorMessage: 'Error al procesar fila: $e',
          ));
        }
      }

      return ExcelParseResult(
        validRecords: validRecords,
        errors: errors,
        totalRows: rows.length - 1,
      );
    } catch (e) {
      return ExcelParseResult(
        validRecords: [],
        errors: [ExcelRowError(rowNumber: 0, errorMessage: 'Error al procesar el archivo: $e')],
        totalRows: 0,
      );
    }
  }
}
