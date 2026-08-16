import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/onu_provider.dart';
import '../../application/providers/catalog_provider.dart';
import '../../domain/models/onu_model.dart';
import '../../domain/models/user_model.dart';
import '../../data/repositories/nap_filter.dart';
import '../widgets/app_shell.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);
const _BG = Color(0xFFF2F2F2);

class OnuFormScreen extends ConsumerStatefulWidget {
  final OnuModel? onu;
  const OnuFormScreen({super.key, this.onu});
  @override
  ConsumerState<OnuFormScreen> createState() => _OnuFormScreenState();
}

class _OnuFormScreenState extends ConsumerState<OnuFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _excelIdController;
  late TextEditingController _serialController;
  late TextEditingController _macController;
  late TextEditingController _ssidController;
  late TextEditingController _passwordController;
  late TextEditingController _clienteController;
  late TextEditingController _napController;
  late TextEditingController _etiquetaController;
  late TextEditingController _txController;
  late TextEditingController _rxController;
  late TextEditingController _tipoInstalacionController;
  String _estadoValue = 'Libre';
  String? _tipoInstalacionValue;

  String? _selectedZona;
  String? _selectedModelo;
  String? _selectedTecnico;
  String? _selectedSoporte;

  @override
  void initState() {
    super.initState();
    final o = widget.onu;
    _excelIdController = TextEditingController(text: o?.excelId ?? '');
    _serialController = TextEditingController(text: o?.numeroSerial ?? '');
    _macController = TextEditingController(text: o?.mac ?? '');
    _ssidController = TextEditingController(text: o?.ssid ?? '');
    _passwordController = TextEditingController(text: o?.password ?? '');
    _clienteController = TextEditingController(text: o?.clienteNombre ?? '');
    _napController = TextEditingController(text: o?.nap ?? '');
    _etiquetaController = TextEditingController(text: o?.etiqueta ?? '');
    _txController = TextEditingController(text: (o != null && o.tx != 0) ? o.tx.toString() : '');
    _rxController = TextEditingController(text: (o != null && o.rx != 0) ? o.rx.toString() : '');
    final tipoRaw = o?.tipoInstalacion ?? '';
    _tipoInstalacionController = TextEditingController(text: tipoRaw);
    _tipoInstalacionValue = ['N/A', 'Nuevo', 'Cambio de ONT', 'Cambio a fibra'].contains(tipoRaw) ? tipoRaw : null;
    _estadoValue = (o != null && o.estado.isNotEmpty) ? o.estado : 'Libre';
    if (_estadoValue != 'Ocupada' && _estadoValue != 'Libre' && _estadoValue != 'Defectuosa') {
      _estadoValue = 'Libre';
    }
    _selectedZona = o?.localidad;
    _selectedModelo = o?.modeloOnt;
    _selectedTecnico = o?.tecnicoInstalador;
    _selectedSoporte = o?.soporteProvision;
  }

  @override
  void dispose() {
    _excelIdController.dispose();
    _serialController.dispose();
    _macController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    _clienteController.dispose();
    _napController.dispose();
    _etiquetaController.dispose();
    _txController.dispose();
    _rxController.dispose();
    _tipoInstalacionController.dispose();
    super.dispose();
  }

  String _val(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? 'N/A' : t;
  }

  InputDecoration _dec(String label, {IconData? prefix, bool editable = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: editable ? Colors.grey.shade600 : Colors.grey.shade400),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _O, width: 2)),
      filled: true,
      fillColor: editable ? Colors.white : Colors.grey.shade100,
      prefixIcon: prefix != null ? Icon(prefix, size: 20, color: editable ? Colors.grey.shade500 : Colors.grey.shade400) : null,
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newOnu = OnuModel(
          id: widget.onu?.id,
          excelId: _val(_excelIdController),
          numeroSerial: _val(_serialController),
          mac: _val(_macController),
          ssid: _val(_ssidController),
          password: _val(_passwordController),
          clienteNombre: _val(_clienteController),
          localidad: _selectedZona ?? 'N/A',
          nap: _val(_napController),
          etiqueta: _val(_etiquetaController),
          modeloOnt: _selectedModelo ?? 'N/A',
          tx: double.tryParse(_txController.text.trim().replaceAll(',', '.')) ?? 0.0,
          rx: double.tryParse(_rxController.text.trim().replaceAll(',', '.')) ?? 0.0,
          estado: _estadoValue,
          tipoInstalacion: _tipoInstalacionValue ?? 'N/A',
          tecnicoInstalador: _selectedTecnico ?? 'N/A',
          soporteProvision: _selectedSoporte ?? 'N/A',
        );

        final actions = ref.read(onuActionsProvider);
        if (widget.onu == null) {
          await actions.createOnu(newOnu);
        } else {
          await actions.updateOnu(widget.onu!.id!, newOnu);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Guardado'), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          context.go('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final role = user?.role;
    final isAdmin = role == UserRole.admin;
    final isBodega = role == UserRole.bodega;
    final isEditing = widget.onu != null;
    final catalogs = ref.watch(catalogsStreamProvider).value;
    final requireAll = !isAdmin && !isBodega; // soporte requiere todos los campos

    final napsOrdenados = (catalogs?.naps ?? []).toList()..sort();
    final napsDisponibles = filtrarNapsPorLocalidad(napsOrdenados, _selectedZona, catalogs?.prefijos);
    if (!napsDisponibles.contains('N/A')) napsDisponibles.insert(0, 'N/A');

    return Scaffold(
      backgroundColor: _BG,
      body: Column(
        children: [
          AppTopBar(user: user, ref: ref),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSidebar(isAdmin: isAdmin, active: 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(isEditing),
                              const SizedBox(height: 24),

                              // ID del Excel
                              _SectionCard(title: 'Identificador', icon: Icons.tag, children: [
                                _fld(_excelIdController, 'ID (Excel)', prefix: Icons.numbers, required: false,
                                  helper: 'Opcional. Puede repetirse, Firestore asigna ID único.'),
                              ]),

                              // ── Datos de Red (obligatorios para todos) ──
                              _SectionCard(title: 'Datos de Red', icon: Icons.lan_outlined, children: [
                                _fld(_serialController, 'Número Serial', prefix: Icons.qr_code_2, editable: isAdmin, required: true),
                                _fld(_macController, 'Dirección MAC', prefix: Icons.wifi, editable: isAdmin, required: true),
                                _fld(_ssidController, 'SSID', prefix: Icons.wifi_find, editable: isAdmin, required: true),
                                _fld(_passwordController, 'Password WiFi', prefix: Icons.key, editable: isAdmin, required: true),
                                if (isAdmin) _buildModemDropdown(catalogs?.modelos ?? []) else _fld(TextEditingController(text: _selectedModelo ?? ''), 'Modelo de ONT', prefix: Icons.router_outlined, editable: false, required: false),
                                if (!isBodega) _buildEstadoDropdown(required: true),
                              ]),

                              // ── Datos Generales (N/A por defecto para admin/bodega) ──
                              _SectionCard(title: 'Datos Generales', icon: Icons.description_outlined, children: [
                                _fld(_txController, 'TX — Potencia Óptica (dBm)', prefix: Icons.arrow_upward, isNumber: true, required: requireAll),
                                _fld(_rxController, 'RX — Potencia Óptica (dBm)', prefix: Icons.arrow_downward, isNumber: true, required: requireAll),
                                _fld(_clienteController, 'Nombre del Cliente', prefix: Icons.person_outline, required: requireAll),
                                if (!isBodega)
                                  _buildCatalogDropdown(label: 'Zona / Localidad', value: _selectedZona, items: catalogs?.zonas ?? [], icon: Icons.location_on_outlined, required: requireAll,
                                    onChanged: (v) => setState(() { _selectedZona = v; _napController.clear(); })),
                                if (!isBodega && _selectedZona != null && napsDisponibles.isNotEmpty)
                                  _buildNapDropdown(napsDisponibles, required: requireAll)
                                else
                                  _fld(_napController, 'NAP', prefix: Icons.cable, required: requireAll),
                                _fld(_etiquetaController, 'Etiqueta', prefix: Icons.label_outline, required: requireAll),
                                if (!isBodega) _buildTipoInstalacionDropdown(required: requireAll),
                                if (!isBodega) ...[
                                  _buildCatalogDropdown(label: 'Técnico Instalador', value: _selectedTecnico, items: catalogs?.tecnicos ?? [], icon: Icons.handyman_outlined, required: requireAll,
                                    onChanged: (v) => setState(() => _selectedTecnico = v)),
                                  _buildCatalogDropdown(label: 'Soporte Provisión', value: _selectedSoporte, items: catalogs?.soportes ?? [], icon: Icons.headset_mic_outlined, required: requireAll,
                                    onChanged: (v) => setState(() => _selectedSoporte = v)),
                                ],
                                if (isBodega)
                                  Padding(padding: const EdgeInsets.only(top: 4), child: Text('Los demás datos serán completados por otros responsables.',
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontStyle: FontStyle.italic))),
                              ]),

                              const SizedBox(height: 20),
                              _buildSaveButton(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _O.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(isEditing ? Icons.edit_outlined : Icons.add_circle_outline, color: _O, size: 24)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isEditing ? 'Editar ONU' : 'Nueva ONU', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _N)),
        Text(isEditing ? 'Modifica los campos necesarios' : 'Completa los datos de red (el resto es opcional)', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      ]),
    ]);
  }

  Widget _buildSaveButton() {
    return Center(child: SizedBox(width: 280, height: 50, child: ElevatedButton.icon(
      onPressed: _save, icon: const Icon(Icons.save_outlined, size: 22),
      label: const Text('Guardar Cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(backgroundColor: _O, foregroundColor: Colors.white, elevation: 2,
        shadowColor: _O.withValues(alpha: 0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    )));
  }

  // ── FIELD ──
  Widget _fld(TextEditingController c, String label, {bool isNumber = false, bool editable = true, IconData? prefix, required bool required, String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        readOnly: !editable,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.,\-]'))] : null,
        style: TextStyle(color: editable ? Colors.black87 : Colors.grey.shade600, fontSize: 14),
        decoration: _dec(label, prefix: prefix, editable: editable).copyWith(helperText: helper, helperStyle: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null : null,
      ),
    );
  }

  // ── ESTADO DROPDOWN ──
  Widget _buildEstadoDropdown({bool required = false}) {
    const colors = {'Ocupada': Colors.green, 'Libre': Colors.orange, 'Defectuosa': Colors.red};
    final cc = colors[_estadoValue] ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _estadoValue,
        decoration: InputDecoration(
          labelText: 'Estado', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.circle, size: 14, color: cc),
          filled: true, fillColor: Colors.white,
        ),
        items: colors.keys.map((e) => DropdownMenuItem(value: e, child: Row(children: [Icon(Icons.circle, size: 12, color: colors[e]), const SizedBox(width: 8), Text(e)]))).toList(),
        onChanged: (val) => setState(() => _estadoValue = val ?? 'Libre'),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null : null,
      ),
    );
  }

  // ── TIPO INSTALACION ──
  Widget _buildTipoInstalacionDropdown({bool required = false}) {
    const items = ['N/A', 'Nuevo', 'Cambio de ONT', 'Cambio a fibra'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _tipoInstalacionValue, hint: const Text('Seleccionar'),
        decoration: _dec('Tipo Instalación', prefix: Icons.build_outlined),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: (v) => setState(() { _tipoInstalacionValue = v; if (v != null) _tipoInstalacionController.text = v; }),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null : null,
      ),
    );
  }

  // ── CATALOG DROPDOWN ──
  Widget _buildCatalogDropdown({required String label, required String? value, required List<String> items, required IconData icon, required ValueChanged<String?> onChanged, bool required = false}) {
    final dd = items.toSet().toList();
    if (value != null && value.isNotEmpty && !dd.contains(value)) dd.add(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: (value == null || value.isEmpty) ? null : value,
        decoration: _dec(label, prefix: icon),
        items: dd.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: required ? (val) => (val == null || val.isEmpty) ? 'Requerido' : null : null,
      ),
    );
  }

  // ── NAP DROPDOWN ──
  Widget _buildNapDropdown(List<String> naps, {bool required = false}) {
    final cv = _napController.text.trim().isEmpty ? null : _napController.text.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Autocomplete<String>(
        key: ValueKey('nap_${_selectedZona ?? ''}_${_napController.text}'),
        initialValue: cv != null ? TextEditingValue(text: cv) : null,
        optionsBuilder: (v) => v.text.isEmpty ? naps : naps.where((n) => n.toLowerCase().contains(v.text.toLowerCase())),
        onSelected: (s) => _napController.text = s,
        fieldViewBuilder: (context, c, fn, os) => TextFormField(
          controller: c, focusNode: fn,
          decoration: _dec('NAP', prefix: Icons.cable),
          onFieldSubmitted: (_) => os(),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null : null,
        ),
        optionsViewBuilder: (context, os, opts) => Align(
          alignment: Alignment.topLeft,
          child: Material(elevation: 4, borderRadius: BorderRadius.circular(10), child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(padding: EdgeInsets.zero, shrinkWrap: true, itemCount: opts.length,
              itemBuilder: (_, i) => ListTile(dense: true, leading: const Icon(Icons.cable, size: 18, color: _N), title: Text(opts.elementAt(i), style: const TextStyle(fontSize: 14)), onTap: () => os(opts.elementAt(i)))),
          )),
        ),
      ),
    );
  }

  // ── MODELO DROPDOWN ──
  Widget _buildModemDropdown(List<String> modelos) {
    final cv = (_selectedModelo ?? '').trim();
    final opts = modelos.toSet().toList()..sort();
    if (cv.isNotEmpty && !opts.contains(cv)) opts.insert(0, cv);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Autocomplete<String>(
        initialValue: cv.isNotEmpty ? TextEditingValue(text: cv) : null,
        optionsBuilder: (v) => v.text.isEmpty ? opts : opts.where((m) => m.toLowerCase().contains(v.text.toLowerCase())),
        onSelected: (s) => setState(() => _selectedModelo = s),
        fieldViewBuilder: (context, c, fn, os) {
          if (cv.isNotEmpty && c.text != cv) { c.text = cv; c.selection = TextSelection.fromPosition(TextPosition(offset: c.text.length)); }
          return TextFormField(
            controller: c, focusNode: fn,
            decoration: _dec('Modelo de ONT', prefix: Icons.router_outlined),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            onChanged: (v) => _selectedModelo = v.trim(),
            onFieldSubmitted: (_) { _selectedModelo = c.text.trim(); os(); },
          );
        },
        optionsViewBuilder: (context, os, opts) => Align(
          alignment: Alignment.topLeft,
          child: Material(elevation: 4, borderRadius: BorderRadius.circular(10), child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(padding: EdgeInsets.zero, shrinkWrap: true, itemCount: opts.length,
              itemBuilder: (_, i) => ListTile(dense: true, leading: const Icon(Icons.router_outlined, size: 18, color: _N), title: Text(opts.elementAt(i), style: const TextStyle(fontSize: 14)), onTap: () => os(opts.elementAt(i)))),
          )),
        ),
      ),
    );
  }
}

// ── SECTION CARD ──
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 1, shadowColor: Colors.black.withValues(alpha: 0.06), color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: _N.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: _N, size: 20)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _N)),
            ]),
            const SizedBox(height: 20),
            ...children,
          ]),
        ),
      ),
    );
  }
}
