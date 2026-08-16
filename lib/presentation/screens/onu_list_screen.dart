import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/onu_provider.dart';
import '../../application/providers/catalog_provider.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/onu_model.dart';
import '../widgets/drag_scroll_behavior.dart';
import '../widgets/app_shell.dart';
import '../widgets/advanced_filter_widget.dart';
import '../../application/utils/nap_filter.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);
const _BG = Color(0xFFF2F2F2);

class OnuListScreen extends ConsumerStatefulWidget {
  const OnuListScreen({super.key});
  @override
  ConsumerState<OnuListScreen> createState() => _OnuListScreenState();
}

class _OnuListScreenState extends ConsumerState<OnuListScreen> {
  final _sC = TextEditingController();
  final _pC = TextEditingController();
  final _hC = ScrollController();
  String _q = '';
  int _nav = 1;
  int _pg = 0;
  int _pp = 20;
  List<OnuModel> _fl = [];
  List<OnuModel> _al = [];
  List<OnuModel> _advancedFiltered = [];
  bool _hasAdvancedFilter = false;

  // ── Selección masiva ──
  final Set<String> _selectedIds = {};

  // ── Ordenamiento ──
  String? _sortField;
  bool _sortAscending = true;

  @override
  void dispose() {
    _sC.dispose();
    _pC.dispose();
    _hC.dispose();
    super.dispose();
  }

  // ══════════════════════════════════ SORTING ══════════════════════════════════

  /// Ordena la lista según el campo y dirección actuales
  List<OnuModel> _sortItems(List<OnuModel> items) {
    if (_sortField == null) return items;
    final ascending = _sortAscending;
    final sorted = List<OnuModel>.from(items);

    sorted.sort((a, b) {
      final va = _getSortValue(a, _sortField!);
      final vb = _getSortValue(b, _sortField!);

      // Nulos al final
      if (va == null && vb == null) return 0;
      if (va == null) return 1;
      if (vb == null) return -1;

      int cmp;
      if (va is num && vb is num) {
        cmp = va.compareTo(vb);
      } else {
        cmp = va.toString().toLowerCase().compareTo(vb.toString().toLowerCase());
      }
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  /// Obtiene el valor de ordenamiento para un campo dado
  dynamic _getSortValue(OnuModel o, String field) {
    switch (field) {
      case 'id':
        final n = int.tryParse(o.excelId ?? o.id ?? '');
        return n ?? o.excelId ?? o.id;
      case 'ssid':
        return o.ssid;
      case 'numero_serial':
        return o.numeroSerial;
      case 'mac':
        return o.mac;
      case 'password':
        return o.password;
      case 'cliente_nombre':
        return o.clienteNombre;
      case 'localidad':
        return o.localidad;
      case 'nap':
        return o.nap;
      case 'etiqueta':
        return o.etiqueta;
      case 'modelo_ont':
        return o.modeloOnt;
      case 'tx':
        return o.tx;
      case 'rx':
        return o.rx;
      case 'estado':
        return o.estado;
      case 'tipo_instalacion':
        return o.tipoInstalacion;
      case 'tecnico_instalador':
        return o.tecnicoInstalador;
      case 'soporte_provision':
        return o.soporteProvision;
      default:
        return '';
    }
  }

  void _toggleSort(String field) {
    setState(() {
      if (_sortField == field) {
        if (_sortAscending) {
          _sortAscending = false;
        } else {
          _sortField = null;
          _sortAscending = true;
        }
      } else {
        _sortField = field;
        _sortAscending = true;
      }
      _pg = 0;
    });
  }

  Icon? _sortIcon(String field) {
    if (_sortField != field) return null;
    return Icon(
      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
      size: 12,
      color: _O,
    );
  }

  // ══════════════════════════════════ SELECTION ══════════════════════════════════

  void _toggleSelectAll(List<OnuModel> visibleItems) {
    setState(() {
      final allIds = visibleItems.map((o) => o.id!).toSet();
      if (_selectedIds.containsAll(allIds)) {
        _selectedIds.removeAll(allIds);
      } else {
        _selectedIds.addAll(allIds);
      }
    });
  }

  void _toggleSelectOne(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  bool _isAllSelected(List<OnuModel> visibleItems) {
    if (visibleItems.isEmpty) return false;
    return visibleItems.every((o) => _selectedIds.contains(o.id));
  }

  bool _isSomeSelected(List<OnuModel> visibleItems) {
    return visibleItems.any((o) => _selectedIds.contains(o.id));
  }

  // ══════════════════════════════════ BULK DELETE ══════════════════════════════════

  Future<void> _confirmBulkDelete() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 14),
            const Text('Eliminar ONUs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Se eliminarán ${_selectedIds.length} registro(s) de forma permanente.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'IDs: ${_selectedIds.take(10).join(', ')}${_selectedIds.length > 10 ? '...' : ''}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('Eliminar ${_selectedIds.length}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final actions = ref.read(onuActionsProvider);
      final count = await actions.batchDeleteOnus(_selectedIds.toList());
      setState(() => _selectedIds.clear());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count ONUs eliminadas correctamente.'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ══════════════════════════════════ SEARCH / CSV ══════════════════════════════════

  List<OnuModel> _filt(List<OnuModel> l) {
    final q = _q.toLowerCase().trim();
    if (q.isEmpty) return l;
    final f = l
        .where(
          (o) =>
              o.excelId?.toLowerCase().contains(q) == true ||
              o.id?.toLowerCase().contains(q) == true ||
              o.ssid.toLowerCase().contains(q) ||
              o.clienteNombre.toLowerCase().contains(q) ||
              o.localidad.toLowerCase().contains(q) ||
              o.mac.toLowerCase().contains(q) ||
              o.numeroSerial.toLowerCase().contains(q) ||
              o.nap.toLowerCase().contains(q) ||
              o.etiqueta.toLowerCase().contains(q) ||
              o.modeloOnt.toLowerCase().contains(q) ||
              o.tecnicoInstalador.toLowerCase().contains(q),
        )
        .toList();
    f.sort((a, b) {
      final ai = a.id ?? '', bi = b.id ?? '';
      if (q.isNotEmpty) {
        if (ai.toLowerCase() == q && bi.toLowerCase() != q) return -1;
        if (bi.toLowerCase() == q && ai.toLowerCase() != q) return 1;
        if (ai.toLowerCase().startsWith(q) && !bi.toLowerCase().startsWith(q)) return -1;
        if (bi.toLowerCase().startsWith(q) && !ai.toLowerCase().startsWith(q)) return 1;
      }
      final na = int.tryParse(ai), nb = int.tryParse(bi);
      if (na != null && nb != null) return na.compareTo(nb);
      if (na != null) return -1;
      if (nb != null) return 1;
      return ai.toLowerCase().compareTo(bi.toLowerCase());
    });
    return f;
  }

  Future<void> _sv(WidgetRef r, OnuModel o, String k, String v) async {
    final t = v.trim();
    final x = t.isEmpty ? 'N/A' : t;
    final ac = r.read(onuActionsProvider);
    OnuModel u;
    switch (k) {
      case 'numero_serial': u = o.copyWith(numeroSerial: x);
      case 'mac': u = o.copyWith(mac: x);
      case 'ssid': u = o.copyWith(ssid: x);
      case 'password': u = o.copyWith(password: x);
      case 'cliente_nombre': u = o.copyWith(clienteNombre: x);
      case 'localidad': u = o.copyWith(localidad: x);
      case 'nap': u = o.copyWith(nap: x);
      case 'etiqueta': u = o.copyWith(etiqueta: x);
      case 'modelo_ont': u = o.copyWith(modeloOnt: x);
      case 'tx': u = o.copyWith(tx: double.tryParse(t) ?? 0.0);
      case 'rx': u = o.copyWith(rx: double.tryParse(t) ?? 0.0);
      case 'estado': u = o.copyWith(estado: x);
      case 'tipo_instalacion': u = o.copyWith(tipoInstalacion: x);
      case 'tecnico_instalador': u = o.copyWith(tecnicoInstalador: x);
      case 'soporte_provision': u = o.copyWith(soporteProvision: x);
      default: return;
    }
    try {
      await ac.updateOnu(o.id!, u);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Guardado'), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
    }
  }

  void _csv() {
    final d = _al.isNotEmpty ? _al : _fl;
    if (d.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin datos'), behavior: SnackBarBehavior.floating));
      return;
    }
    String e(String v) =>
        (v.contains(',') || v.contains('"') || v.contains('\n')) ? '"${v.replaceAll('"', '""')}"' : v;
    final h = 'ID,SSID,Serial,MAC,Password,Cliente,Localidad,NAP,Etiqueta,Modelo ONT,TX,RX,Estado,Tipo Instalacion,Tecnico,Soporte';
    final rs = d.map((o) => [
                  e(o.excelId ?? o.id ?? ''), e(o.ssid), e(o.numeroSerial), e(o.mac), e(o.password),
      e(o.clienteNombre), e(o.localidad), e(o.nap), e(o.etiqueta), e(o.modeloOnt),
      o.tx.toString(), o.rx.toString(), e(o.estado), e(o.tipoInstalacion),
      e(o.tecnicoInstalador), e(o.soporteProvision),
    ].join(',')).join('\n');
    final blob = web.Blob([utf8.encode('$h\n$rs').toJS].toJS, web.BlobPropertyBag(type: 'text/csv;charset=utf-8;'));
    final url = web.URL.createObjectURL(blob);
    final n = 'onus_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.csv';
    final a = web.document.createElement('a') as web.HTMLAnchorElement;
    a.href = url; a.setAttribute('download', n);
    web.document.body!.appendChild(a); a.click(); web.document.body!.removeChild(a); web.URL.revokeObjectURL(url);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Descargando $n (${d.length} registros)'), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating,));
  }

  // ══════════════════════════════════ BUILD ══════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final onus = ref.watch(onusStreamProvider);
    final user = ref.watch(currentUserProvider).value;
    final role = user?.role;
    final isAdmin = role == UserRole.admin;
    final isBodega = role == UserRole.bodega;
    final canDelete = isAdmin || isBodega;
    final narrow = MediaQuery.of(context).size.width < 700;
    final now = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: _BG,
      drawer: narrow ? Drawer(child: AppSidebar(isAdmin: isAdmin, active: _nav, onDownloadCsv: (isAdmin || isBodega) ? _csv : null)) : null,
      body: Column(
        children: [
          AppTopBar(date: date, user: user, ref: ref),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!narrow) AppSidebar(isAdmin: isAdmin, active: _nav, onDownloadCsv: (isAdmin || isBodega) ? _csv : null),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: onus.when(
                          data: (list) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                                child: TextField(
                                  controller: _sC,
                                  onChanged: (v) => setState(() { _q = v; _pg = 0; }),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar por ID, SSID, Cliente, Serial, MAC...',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                                    suffixIcon: _q.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 16),
                                            onPressed: () { _sC.clear(); setState(() { _q = ''; _pg = 0; }); },
                                          )
                                        : null,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _O, width: 1.5)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                                child: AdvancedFilterWidget(
                                  allItems: list,
                                  totalCount: list.length,
                                  onFilterChanged: (filtered) {
                                    setState(() {
                                      _advancedFiltered = filtered;
                                      _hasAdvancedFilter = filtered.length != list.length;
                                      _pg = 0;
                                    });
                                  },
                                ),
                              ),
                              Expanded(child: _buildContent(list, canDelete, isAdmin)),
                            ],
                          ),
                          loading: () => const Center(child: CircularProgressIndicator(color: _O)),
                          error: (e, _) => Center(child: Text('Error: $e')),
                        ),
                      ),
                      const _Foot(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<OnuModel> list, bool canDelete, bool isAdmin) {
    final baseList = _hasAdvancedFilter ? _advancedFiltered : list;
    final hasSearch = _q.trim().isNotEmpty;

    if (!_hasAdvancedFilter && !hasSearch) return _EmptyState();

    List<OnuModel> filtered;
    if (_hasAdvancedFilter && !hasSearch) {
      filtered = baseList;
    } else if (hasSearch) {
      filtered = _filt(baseList);
    } else {
      filtered = list;
    }

    // Aplicar ordenamiento
    filtered = _sortItems(filtered);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_al.length != list.length) setState(() => _al = list);
      if (_fl.length != filtered.length) setState(() => _fl = filtered);
    });

    if (filtered.isEmpty) return _EmptyResults();

    final pages = (filtered.length / _pp).ceil();
    final p = _pg.clamp(0, pages > 0 ? pages - 1 : 0);
    final s = p * _pp;
    final end = (s + _pp).clamp(0, filtered.length);
    final items = filtered.sublist(s, end);

    // Limpiar selecciones que ya no están en la vista filtrada
    final visibleIds = items.map((o) => o.id!).toSet();
    _selectedIds.removeWhere((id) => !visibleIds.contains(id) && !filtered.any((o) => o.id == id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          Expanded(
            child: Card(
              elevation: 2, color: Colors.white, shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.table_chart_outlined, size: 20, color: _N),
                          const SizedBox(width: 10),
                          const Text('Lista de Equipos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _N)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: _O.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                            child: Text('${filtered.length} de ${list.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _O)),
                          ),
                          const Spacer(),
                          if (canDelete && _selectedIds.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text('${_selectedIds.length} seleccionado(s)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: _confirmBulkDelete,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.delete_forever, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text('Eliminar', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(child: _buildTable(items, canDelete, isAdmin)),
                  ],
                ),
              ),
            ),
          ),
          _Pag(
            total: filtered.length, pages: pages, page: p, per: _pp, pCtrl: _pC,
            onPer: (v) => setState(() { _pp = v; _pg = 0; _selectedIds.clear(); }),
            onPage: (v) => setState(() { _pg = v; _pC.clear(); }),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<OnuModel> items, bool canDelete, bool isAdmin) {
    final user = ref.watch(currentUserProvider).value;
    final role = user?.role;
    final isBodega = role == UserRole.bodega;

    final eds = isAdmin
        ? {'numero_serial', 'mac', 'ssid', 'password', 'cliente_nombre', 'localidad', 'nap', 'etiqueta', 'modelo_ont', 'tx', 'rx', 'estado', 'tipo_instalacion', 'tecnico_instalador', 'soporte_provision'}
        : isBodega
            ? {'numero_serial', 'mac', 'password'}
            : {'cliente_nombre', 'localidad', 'nap', 'etiqueta', 'modelo_ont', 'tx', 'rx', 'estado', 'tipo_instalacion', 'tecnico_instalador', 'soporte_provision'};

    final cats = {'localidad': 'zonas', 'modelo_ont': 'modelos', 'tecnico_instalador': 'tecnicos', 'soporte_provision': 'soportes', 'nap': 'naps'};

    return ScrollConfiguration(
      behavior: DragScrollBehavior(),
      child: Scrollbar(
        controller: _hC, thumbVisibility: true, trackVisibility: true,
        notificationPredicate: (n) => n is ScrollUpdateNotification && n.metrics.axis == Axis.horizontal,
        child: SingleChildScrollView(
          controller: _hC, scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            primary: false,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              columnSpacing: 14, horizontalMargin: 10,
              columns: [
                if (canDelete)
                  DataColumn(
                    label: _CheckHeader(
                      checked: _isAllSelected(items),
                      indeterminate: _isSomeSelected(items) && !_isAllSelected(items),
                      onToggle: () => _toggleSelectAll(items),
                    ),
                  ),
                _sortCol('ID', 'id'),
                _sortCol('SSID', 'ssid'),
                _sortCol('Serial', 'numero_serial'),
                _sortCol('MAC', 'mac'),
                _sortCol('Password', 'password'),
                _sortCol('Cliente', 'cliente_nombre'),
                _sortCol('Localidad', 'localidad'),
                _sortCol('NAP', 'nap'),
                _sortCol('Etiqueta', 'etiqueta'),
                _sortCol('Modelo', 'modelo_ont'),
                _sortCol('TX', 'tx'),
                _sortCol('RX', 'rx'),
                _sortCol('Estado', 'estado'),
                _sortCol('Tipo Inst', 'tipo_instalacion'),
                _sortCol('Tecnico', 'tecnico_instalador'),
                _sortCol('Soporte', 'soporte_provision'),
              ],
              rows: items.map((o) => DataRow(
                color: WidgetStateProperty.all(
                  o.estado == 'Ocupada' ? Colors.green.shade50.withValues(alpha: 0.3) : Colors.white,
                ),
                cells: [
                  if (canDelete)
                    DataCell(Checkbox(
                      value: _selectedIds.contains(o.id),
                      onChanged: (_) => _toggleSelectOne(o.id!),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )),
                  DataCell(SelectableText(o.excelId ?? o.id ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  DataCell(_ce(o.ssid, 'ssid', o, eds, cats, ref)),
                  DataCell(_ce(o.numeroSerial, 'numero_serial', o, eds, cats, ref)),
                  DataCell(_ce(o.mac, 'mac', o, eds, cats, ref)),
                  DataCell(_ce(o.password, 'password', o, eds, cats, ref)),
                  DataCell(_ce(o.clienteNombre, 'cliente_nombre', o, eds, cats, ref)),
                  DataCell(_ce(o.localidad, 'localidad', o, eds, cats, ref)),
                  DataCell(_ce(o.nap, 'nap', o, eds, cats, ref)),
                  DataCell(_ce(o.etiqueta, 'etiqueta', o, eds, cats, ref)),
                  DataCell(_ce(o.modeloOnt, 'modelo_ont', o, eds, cats, ref)),
                  DataCell(_ce(o.tx.toString(), 'tx', o, eds, cats, ref)),
                  DataCell(_ce(o.rx.toString(), 'rx', o, eds, cats, ref)),
                  DataCell(_bd(o, role, ref)),
                  DataCell(_ce(o.tipoInstalacion, 'tipo_instalacion', o, eds, cats, ref)),
                  DataCell(_ce(o.tecnicoInstalador, 'tecnico_instalador', o, eds, cats, ref)),
                  DataCell(_ce(o.soporteProvision, 'soporte_provision', o, eds, cats, ref)),
                ],
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye una columna ordenable
  DataColumn _sortCol(String title, String field) {
    final sortIcon = _sortIcon(field);
    return DataColumn(
      onSort: (_, __) => _toggleSort(field),
      label: InkWell(
        onTap: () => _toggleSort(field),
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _sortField == field ? _O : _N)),
            if (sortIcon != null) ...[const SizedBox(width: 2), sortIcon],
          ],
        ),
      ),
    );
  }

  static final _txFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]{0,2}$'))];
  static final _rxFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]{0,2}$'))];

  Widget _ce(String v, String k, OnuModel o, Set<String> eds, Map<String, String> cs, WidgetRef r) {
    if (!eds.contains(k)) return SelectableText(v, style: const TextStyle(fontSize: 12));
    if (cs.containsKey(k)) return _cd(o, v, k, cs[k]!, r);
    if (k == 'tx') return _Edt(v: v, suffix: 'dBm', formatters: _txFormatters, onS: (nv) => _sv(r, o, k, nv));
    if (k == 'rx') return _Edt(v: v, suffix: 'dBm', formatters: _rxFormatters, onS: (nv) => _sv(r, o, k, nv));
    if (k == 'tipo_instalacion') return _buildTipoInstalacionDropdown(o, v, k, r);
    return _Edt(v: v, onS: (nv) => _sv(r, o, k, nv));
  }

  Widget _buildTipoInstalacionDropdown(OnuModel o, String v, String k, WidgetRef r) {
    const items = ['N/A', 'Nuevo', 'Cambio de ONT', 'Cambio a fibra'];
    final val = items.contains(v) ? v : items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, icon: const Icon(Icons.arrow_drop_down, size: 14, color: _O), isDense: true, dropdownColor: Colors.white,
          style: const TextStyle(fontSize: 11, color: _N, fontWeight: FontWeight.w500),
          onChanged: (nv) { if (nv != null && nv != v) _sv(r, o, k, nv); },
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 12)))).toList(),
        ),
      ),
    );
  }

  Widget _bd(OnuModel o, UserRole? ro, WidgetRef r) {
    final can = ro == UserRole.admin || ro == UserRole.soporte;
    Color bg; String lb;
    switch (o.estado.toLowerCase()) {
      case 'ocupada': bg = const Color(0xFF1B5E20); lb = 'Ocupada';
      case 'libre': bg = Colors.orange.shade700; lb = 'Libre';
      case 'defectuosa': bg = Colors.red.shade700; lb = 'Defectuosa';
      default: bg = Colors.orange.shade700; lb = o.estado.isEmpty ? 'Libre' : o.estado;
    }
    final b = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(lb, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
    );
    if (!can) return b;
    return PopupMenuButton<String>(
      tooltip: 'Cambiar estado', padding: EdgeInsets.zero, position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (v) { if (v != o.estado) _sv(r, o, 'estado', v); },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'Ocupada', child: Row(children: [Icon(Icons.circle, size: 10, color: Colors.green.shade700), const SizedBox(width: 8), Text('Ocupada', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700))])),
        PopupMenuItem(value: 'Libre', child: Row(children: [Icon(Icons.circle, size: 10, color: Colors.orange.shade700), const SizedBox(width: 8), Text('Libre', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700))])),
        PopupMenuItem(value: 'Defectuosa', child: Row(children: [Icon(Icons.circle, size: 10, color: Colors.red.shade700), const SizedBox(width: 8), Text('Defectuosa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700))])),
      ],
      child: b,
    );
  }

  Widget _cd(OnuModel o, String v, String fk, String ck, WidgetRef r) {
    final ca = r.watch(catalogsStreamProvider);
    return ca.when(
      data: (c) {
        List<String> items;
        if (ck == 'naps') { items = filtrarNapsPorLocalidad(o.localidad, c.naps, c.prefijos); if (!items.contains('N/A')) items.insert(0, 'N/A'); }
        else { items = ck == 'zonas' ? c.zonas : ck == 'modelos' ? c.modelos : ck == 'tecnicos' ? c.tecnicos : c.soportes; }
        final dd = items.toSet().toList();
        if (v.isNotEmpty && !dd.contains(v)) dd.add(v);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber.shade200)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: v.isNotEmpty ? v : dd.first, icon: const Icon(Icons.arrow_drop_down, size: 14, color: _O), isDense: true, dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 11, color: _N, fontWeight: FontWeight.w500),
              selectedItemBuilder: (_) => dd.map((i) => Text(i, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _N, fontWeight: FontWeight.w500))).toList(),
              onChanged: (nv) { if (nv != null && nv != v) _sv(r, o, fk, nv); },
              items: dd.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 12, color: Colors.black87)))).toList(),
            ),
          ),
        );
      },
      loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => _Edt(v: v, onS: (nv) => _sv(r, o, fk, nv)),
    );
  }
}

// ══════════════════════════════════ CHECKBOX HEADER ══════════════════════════════════
class _CheckHeader extends StatelessWidget {
  final bool checked;
  final bool indeterminate;
  final VoidCallback onToggle;
  const _CheckHeader({required this.checked, required this.indeterminate, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          indeterminate ? Icons.indeterminate_check_box : checked ? Icons.check_box : Icons.check_box_outline_blank,
          size: 18, color: checked || indeterminate ? _O : Colors.grey.shade400,
        ),
      ),
    );
  }
}

// ══════════════════════════════════ EDITABLE CELL ══════════════════════════════════
class _Edt extends StatefulWidget {
  final String v;
  final String? suffix;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String> onS;
  const _Edt({required this.v, this.suffix, this.formatters, required this.onS});
  @override
  State<_Edt> createState() => _EdtState();
}

class _EdtState extends State<_Edt> {
  late TextEditingController _c;
  bool _e = false;
  String _ov = '';

  @override
  void initState() { super.initState(); _c = TextEditingController(text: widget.v); _ov = widget.v; }

  @override
  void didUpdateWidget(covariant _Edt old) {
    super.didUpdateWidget(old);
    if (old.v != widget.v && !_e) { _c.text = widget.v; _ov = widget.v; }
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_e) {
      return GestureDetector(
        onDoubleTap: () => setState(() => _e = true),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.v,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 10, color: _O),
          ],
        ),
      );
    }
    return SizedBox(
      width: 120, height: 36,
      child: TextField(
        controller: _c, autofocus: true, style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true,
          suffixText: widget.suffix, suffixStyle: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _O, width: 1.5)),
        ),
        inputFormatters: widget.formatters,
        onSubmitted: (nv) { if (nv != _ov) widget.onS(nv); setState(() => _e = false); },
        onTapOutside: (_) { if (_c.text != _ov) widget.onS(_c.text); setState(() => _e = false); },
      ),
    );
  }
}

// ══════════════════════════════════ EMPTY STATES ══════════════════════════════════
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Usa el filtro avanzado para buscar equipos', style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Sin resultados', style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════ PAGINATION ══════════════════════════════════
class _Pag extends StatelessWidget {
  final int total, pages, page, per;
  final TextEditingController pCtrl;
  final ValueChanged<int> onPer, onPage;
  const _Pag({required this.total, required this.pages, required this.page, required this.per, required this.pCtrl, required this.onPer, required this.onPage});

  @override
  Widget build(BuildContext context) {
    final s = page * per + 1;
    final e = ((page + 1) * per).clamp(0, total);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text('Filas:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(width: 6),
            DropdownButton<int>(
              value: per, isDense: true, underline: const SizedBox(),
              items: [10, 20, 50, 100].map((v) => DropdownMenuItem(value: v, child: Text('$v', style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) { if (v != null) onPer(v); },
            ),
            const SizedBox(width: 14),
            Text('$s–$e de $total', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ]),
          Row(children: [
            IconButton(icon: const Icon(Icons.first_page, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page > 0 ? () => onPage(0) : null),
            IconButton(icon: const Icon(Icons.chevron_left, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page > 0 ? () => onPage(page - 1) : null),
            SizedBox(width: 32, height: 24, child: TextField(
              controller: pCtrl, textAlign: TextAlign.center, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(hintText: '${page + 1}', border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2), isDense: true),
              onSubmitted: (v) { final p = int.tryParse(v); if (p != null) onPage((p - 1).clamp(0, pages - 1)); },
            )),
            Text(' de $pages', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            IconButton(icon: const Icon(Icons.chevron_right, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page < pages - 1 ? () => onPage(page + 1) : null),
            IconButton(icon: const Icon(Icons.last_page, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page < pages - 1 ? () => onPage(pages - 1) : null),
          ]),
        ],
      ),
    );
  }
}

// ══════════════════════════════════ FOOTER ══════════════════════════════════
class _Foot extends StatelessWidget {
  const _Foot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), color: Colors.white,
      child: Text('© ${DateTime.now().year} Company', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
    );
  }
}
