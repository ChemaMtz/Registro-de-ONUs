import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/catalog_provider.dart';
import '../../domain/models/onu_model.dart';
import '../../domain/models/catalog_model.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);

/// Campos disponibles para filtrar
class FilterField {
  final String key;
  final String label;
  final bool isNumeric;

  const FilterField({
    required this.key,
    required this.label,
    this.isNumeric = false,
  });
}

final List<FilterField> filterFields = [
  const FilterField(key: 'id', label: 'ID'),
  const FilterField(key: 'numero_serial', label: 'Serial'),
  const FilterField(key: 'mac', label: 'MAC'),
  const FilterField(key: 'ssid', label: 'SSID'),
  const FilterField(key: 'password', label: 'Password'),
  const FilterField(key: 'cliente_nombre', label: 'Cliente'),
  const FilterField(key: 'localidad', label: 'Localidad'),
  const FilterField(key: 'nap', label: 'NAP'),
  const FilterField(key: 'etiqueta', label: 'Etiqueta'),
  const FilterField(key: 'modelo_ont', label: 'Modelo ONT'),
  const FilterField(key: 'tx', label: 'TX (dBm)', isNumeric: true),
  const FilterField(key: 'rx', label: 'RX (dBm)', isNumeric: true),
  const FilterField(key: 'estado', label: 'Estado'),
  const FilterField(key: 'tipo_instalacion', label: 'Tipo Instalación'),
  const FilterField(key: 'tecnico_instalador', label: 'Técnico'),
  const FilterField(key: 'soporte_provision', label: 'Soporte'),
];

/// Widget principal de filtro avanzado - ConsumerStatefulWidget para acceso al catálogo
class AdvancedFilterWidget extends ConsumerStatefulWidget {
  final List<OnuModel> allItems;
  final ValueChanged<List<OnuModel>> onFilterChanged;
  final int totalCount;

  const AdvancedFilterWidget({
    super.key,
    required this.allItems,
    required this.onFilterChanged,
    required this.totalCount,
  });

  @override
  ConsumerState<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends ConsumerState<AdvancedFilterWidget> {
  String _selectedField = 'cliente_nombre';
  String _searchValue = '';
  final _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  FilterField get _currentField =>
      filterFields.firstWhere((f) => f.key == _selectedField);

  /// Determina si un campo debe mostrar dropdown en vez de input de texto
  bool _isCatalogField(String key) {
    return ['localidad', 'modelo_ont', 'tecnico_instalador', 'soporte_provision', 'estado', 'tipo_instalacion'].contains(key);
  }

  /// Obtiene la lista de opciones para el dropdown según el campo y el catálogo
  List<String> _getDropdownOptions(String key, CatalogModel? catalog) {
    switch (key) {
      case 'localidad':
        return catalog?.zonas ?? [];

      case 'modelo_ont':
        return catalog?.modelos ?? [];
      case 'tecnico_instalador':
        return catalog?.tecnicos ?? [];
      case 'soporte_provision':
        return catalog?.soportes ?? [];
      case 'estado':
        return ['Libre', 'Ocupada', 'Defectuosa'];
      case 'tipo_instalacion':
        return ['N/A', 'Nuevo', 'Cambio de ONT', 'Cambio a fibra'];
      default:
        return [];
    }
  }

  /// Función principal de filtrado
  List<OnuModel> aplicarFiltro(String campo, String valor) {
    if (valor.isEmpty) return widget.allItems;

    final valorLower = valor.toLowerCase().trim();

    return widget.allItems.where((onu) {
      final fieldValue = _getFieldValue(onu, campo);

      if (campo == 'tx' || campo == 'rx') {
        final numStr = fieldValue.toString();
        return numStr.contains(valor);
      }

      return fieldValue.toLowerCase().contains(valorLower);
    }).toList();
  }

  String _getFieldValue(OnuModel onu, String campo) {
    switch (campo) {
      case 'id': return onu.excelId ?? onu.id ?? '';
      case 'numero_serial': return onu.numeroSerial;
      case 'mac': return onu.mac;
      case 'ssid': return onu.ssid;
      case 'password': return onu.password;
      case 'cliente_nombre': return onu.clienteNombre;
      case 'localidad': return onu.localidad;
      case 'nap': return onu.nap;
      case 'etiqueta': return onu.etiqueta;
      case 'modelo_ont': return onu.modeloOnt;
      case 'tx': return onu.tx.toString();
      case 'rx': return onu.rx.toString();
      case 'estado': return onu.estado;
      case 'tipo_instalacion': return onu.tipoInstalacion;
      case 'tecnico_instalador': return onu.tecnicoInstalador;
      case 'soporte_provision': return onu.soporteProvision;
      default: return '';
    }
  }

  void _applyFilter() {
    final filtered = aplicarFiltro(_selectedField, _searchValue);
    widget.onFilterChanged(filtered);
  }

  void _resetFilter() {
    setState(() {
      _searchValue = '';
      _searchController.clear();
    });
    widget.onFilterChanged(widget.allItems);
  }

  void _onFieldChanged(String? newField) {
    if (newField == null) return;
    setState(() {
      _selectedField = newField;
      _searchValue = '';
      _searchController.clear();
    });
    widget.onFilterChanged(widget.allItems);
  }

  void _onDropdownChanged(String value) {
    setState(() => _searchValue = value);
    _applyFilter();
  }

  void _onTextChanged(String value) {
    setState(() => _searchValue = value);
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogsConfigStreamProvider);

    final filteredCount = _searchValue.isEmpty
        ? widget.totalCount
        : aplicarFiltro(_selectedField, _searchValue).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header compacto
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: _O, size: 20),
                  const SizedBox(width: 10),
                  const Text('Filtro Avanzado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _N)),
                  const SizedBox(width: 12),
                  if (_searchValue.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _O.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('$filteredCount resultados', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _O)),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _resetFilter,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 14, color: Colors.red.shade600),
                            const SizedBox(width: 4),
                            Text('Limpiar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.red.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 20),
                ],
              ),
            ),
          ),

          // Contenido expandible
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  catalogAsync.when(
                    data: (catalog) => _buildFilterUI(catalog),
                    loading: () => _buildFilterUI(null),
                    error: (_, __) => _buildFilterUI(null),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterUI(CatalogModel? catalog) {
    final isCatalogField = _isCatalogField(_selectedField);
    final options = isCatalogField ? _getDropdownOptions(_selectedField, catalog) : <String>[];

    return Column(
      children: [
        Row(
          children: [
            // Selector de campo
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedField,
                    isExpanded: true,
                    isDense: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderRadius: BorderRadius.circular(10),
                    items: filterFields.map((f) => DropdownMenuItem(value: f.key, child: Text(f.label, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: _onFieldChanged,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dropdown de opciones O input de texto
            Expanded(
              flex: 3,
              child: isCatalogField
                  ? _buildDropdown(options, _selectedField)
                  : _buildSearchInput(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFieldInfo(isCatalogField, options.length),
      ],
    );
  }

  /// Dropdown con opciones del catálogo (con buscador rápido)
  Widget _buildDropdown(List<String> options, String fieldKey) {
    if (options.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text('Cargando opciones...', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      );
    }

    // Valor actual (buscar coincidencia exacta)
    final hasCurrent = options.any((o) => o == _searchValue);
    final currentValue = hasCurrent ? _searchValue : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          isDense: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Seleccionar...', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(10),
          menuMaxHeight: 300,
          // Filtro dentro del dropdown para búsqueda rápida
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) {
            if (v != null) _onDropdownChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      controller: _searchController,
      onChanged: _onTextChanged,
      keyboardType: _currentField.isNumeric
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      inputFormatters: _currentField.isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))]
          : null,
      decoration: InputDecoration(
        hintText: _currentField.isNumeric ? 'Ej: -22.5' : 'Escribe para buscar...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
        suffixIcon: _searchValue.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 16),
                onPressed: () { _searchController.clear(); _onTextChanged(''); },
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _O, width: 1.5)),
      ),
    );
  }

  Widget _buildFieldInfo(bool isCatalogField, int optionsCount) {
    String info;
    IconData icon;

    if (isCatalogField) {
      info = '$optionsCount opciones disponibles - selecciona de la lista';
      icon = Icons.list_alt;
    } else if (_currentField.isNumeric) {
      info = 'Busca por valor numérico (ej: -22, 2.3)';
      icon = Icons.pin;
    } else {
      info = 'Búsqueda libre por texto (no distingue mayúsculas)';
      icon = Icons.text_fields;
    }

    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(info, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
      ],
    );
  }
}
