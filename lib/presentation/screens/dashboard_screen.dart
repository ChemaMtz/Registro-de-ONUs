import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/onu_provider.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/onu_model.dart';
import '../widgets/app_shell.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);
const _BG = Color(0xFFF2F2F2);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onusAsync = ref.watch(onusStreamProvider);
    final user = ref.watch(currentUserProvider).value;
    final narrow = MediaQuery.of(context).size.width < 700;
    final now = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: _BG,
      drawer: narrow ? Drawer(child: AppSidebar(isAdmin: isAdmin, active: 0)) : null,
      body: Column(
        children: [
          AppTopBar(date: date, user: user, ref: ref),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!narrow) AppSidebar(isAdmin: isAdmin, active: 0),
                Expanded(
                  child: onusAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: _O)),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (onus) => _DashboardContent(onus: onus),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final List<OnuModel> onus;
  const _DashboardContent({required this.onus});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  String? _selectedNap;
  String? _selectedModel;

  @override
  Widget build(BuildContext context) {
    final clientesPorLocalidad = <String, int>{};
    final napCounts = <String, int>{};
    final modelCounts = <String, int>{};
    int ocupadas = 0, libres = 0, defectuosas = 0;
    final soporteProvision = <String, int>{};
    final tecnicoInstalador = <String, int>{};

    for (final onu in widget.onus) {
      final loc = onu.localidad.trim();
      if (loc.isNotEmpty && loc.toUpperCase() != 'N/A' && loc.toUpperCase() != 'POR ASIGNAR') {
        clientesPorLocalidad[loc] = (clientesPorLocalidad[loc] ?? 0) + 1;
      }
      final nap = onu.nap.trim();
      if (nap.isNotEmpty && nap.toUpperCase() != 'N/A' && nap.toUpperCase() != 'POR ASIGNAR') {
        napCounts[nap] = (napCounts[nap] ?? 0) + 1;
      }
      final modelo = onu.modeloOnt.trim();
      if (modelo.isNotEmpty && modelo.toUpperCase() != 'N/A') {
        modelCounts[modelo] = (modelCounts[modelo] ?? 0) + 1;
      }
      switch (onu.estado.trim().toLowerCase()) {
        case 'ocupada': ocupadas++; break;
        case 'defectuosa': defectuosas++; break;
        default: libres++;
      }
      final soporte = onu.soporteProvision.trim();
      if (soporte.isNotEmpty && soporte.toUpperCase() != 'N/A' && soporte.toUpperCase() != 'POR ASIGNAR') {
        soporteProvision[soporte] = (soporteProvision[soporte] ?? 0) + 1;
      }
      final tecnico = onu.tecnicoInstalador.trim();
      if (tecnico.isNotEmpty && tecnico.toUpperCase() != 'N/A' && tecnico.toUpperCase() != 'POR ASIGNAR') {
        tecnicoInstalador[tecnico] = (tecnicoInstalador[tecnico] ?? 0) + 1;
      }
    }

    final sortedLocalidades = clientesPorLocalidad.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sortedSoporte = soporteProvision.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sortedTecnicos = tecnicoInstalador.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final napList = napCounts.keys.toList()..sort();
    final modelList = modelCounts.keys.toList()..sort();

    final selectedNap = napCounts.containsKey(_selectedNap) ? _selectedNap : (napList.isNotEmpty ? napList.first : null);
    final selectedNapCount = selectedNap == null ? '0' : (napCounts[selectedNap] ?? 0).toString();
    final selectedModel = modelCounts.containsKey(_selectedModel) ? _selectedModel : (modelList.isNotEmpty ? modelList.first : null);
    final selectedModelCount = selectedModel == null ? '0' : (modelCounts[selectedModel] ?? 0).toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Panel General', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _N)),
          const SizedBox(height: 24),
          Wrap(spacing: 16, runSpacing: 16, children: [
            _MetricCard(title: 'ONUs Ocupadas', value: ocupadas.toString(), icon: Icons.person, color: Colors.green),
            _MetricCard(title: 'ONUs Libres', value: libres.toString(), icon: Icons.inbox, color: Colors.blue),
            _MetricCard(title: 'ONUs Defectuosas', value: defectuosas.toString(), icon: Icons.report_problem, color: Colors.red),
            _NapMetricCard(title: 'NAP', value: selectedNapCount, icon: Icons.cable, color: Colors.orange, naps: napList, selectedNap: selectedNap, onChanged: (v) => setState(() => _selectedNap = v)),
            _NapMetricCard(title: 'Modem', value: selectedModelCount, icon: Icons.devices, color: Colors.purple, naps: modelList, selectedNap: selectedModel, onChanged: (v) => setState(() => _selectedModel = v)),
          ]),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  _ListCard(title: 'Clientes por Localidad', icon: Icons.location_on, items: sortedLocalidades),
                  const SizedBox(height: 16),
                  _ListCard(title: 'Provisiones por Soporte', icon: Icons.support_agent, items: sortedSoporte),
                  const SizedBox(height: 16),
                  _ListCard(title: 'Instalaciones por Técnico', icon: Icons.engineering, items: sortedTecnicos),
                ]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _ListCard(title: 'Clientes por Localidad', icon: Icons.location_on, items: sortedLocalidades)),
                const SizedBox(width: 16),
                Expanded(child: Column(children: [
                  _ListCard(title: 'Provisiones por Soporte', icon: Icons.support_agent, items: sortedSoporte),
                  const SizedBox(height: 16),
                  _ListCard(title: 'Instalaciones por Técnico', icon: Icons.engineering, items: sortedTecnicos),
                ])),
              ]);
            },
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 16),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _N)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _NapMetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final List<String> naps;
  final String? selectedNap;
  final ValueChanged<String?> onChanged;
  const _NapMetricCard({required this.title, required this.value, required this.icon, required this.color, required this.naps, required this.selectedNap, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 16),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _N)),
        const SizedBox(height: 4),
        Row(children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: PopupMenuButton<String>(
            enabled: naps.isNotEmpty, tooltip: naps.isNotEmpty ? 'Seleccionar' : 'Sin datos', padding: EdgeInsets.zero,
            onSelected: (v) => onChanged(v),
            itemBuilder: (_) => naps.map((n) => PopupMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
            child: Row(children: [
              Expanded(child: Text(selectedNap ?? 'Seleccionar', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: naps.isNotEmpty ? Colors.grey.shade800 : Colors.grey.shade500))),
              Icon(Icons.expand_more, size: 18, color: Colors.grey.shade500),
            ]),
          )),
        ]),
      ]),
    );
  }
}

class _ListCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<MapEntry<String, int>> items;
  const _ListCard({required this.title, required this.icon, required this.items});

  @override
  State<_ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<_ListCard> {
  int _pg = 0, _pp = 5;
  late TextEditingController _pC;

  @override
  void initState() { super.initState(); _pC = TextEditingController(); }
  @override
  void dispose() { _pC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pages = (widget.items.length / _pp).ceil();
    if (_pg >= pages && pages > 0) _pg = pages - 1;
    final displayItems = widget.items.skip(_pg * _pp).take(_pp).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(widget.icon, color: _N, size: 20), const SizedBox(width: 8), Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _N))]),
        const SizedBox(height: 16),
        if (widget.items.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey.shade500))))
        else ...[
          ListView.separated(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: displayItems.length, separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(displayItems[i].key, style: const TextStyle(fontSize: 14, color: _N, fontWeight: FontWeight.w500))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _O.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(displayItems[i].value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: _O, fontSize: 13))),
              ]),
            ),
          ),
          if (widget.items.length > 5) ...[
            const SizedBox(height: 16),
            _DashPag(total: widget.items.length, pages: pages, page: _pg, per: _pp, pCtrl: _pC,
              onPer: (v) => setState(() { _pp = v; _pg = 0; }),
              onPage: (v) => setState(() { _pg = v; _pC.clear(); })),
          ],
        ],
      ]),
    );
  }
}

class _DashPag extends StatelessWidget {
  final int total, pages, page, per;
  final TextEditingController pCtrl;
  final ValueChanged<int> onPer, onPage;
  const _DashPag({required this.total, required this.pages, required this.page, required this.per, required this.pCtrl, required this.onPer, required this.onPage});

  @override
  Widget build(BuildContext context) {
    final s = page * per + 1;
    final e = ((page + 1) * per).clamp(0, total);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text('Filas:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 6),
          DropdownButton<int>(value: per, isDense: true, underline: const SizedBox(),
            items: [5, 10, 20, 50].map((v) => DropdownMenuItem(value: v, child: Text('$v', style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) { if (v != null) onPer(v); }),
          const SizedBox(width: 14),
          Text('$s–$e de $total', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
        Row(children: [
          IconButton(icon: const Icon(Icons.first_page, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page > 0 ? () => onPage(0) : null),
          IconButton(icon: const Icon(Icons.chevron_left, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page > 0 ? () => onPage(page - 1) : null),
          SizedBox(width: 32, height: 24, child: TextField(controller: pCtrl, textAlign: TextAlign.center, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(hintText: '${page + 1}', border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2), isDense: true),
            onSubmitted: (v) { final p = int.tryParse(v); if (p != null) onPage((p - 1).clamp(0, pages - 1)); })),
          Text(' de $pages', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          IconButton(icon: const Icon(Icons.chevron_right, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page < pages - 1 ? () => onPage(page + 1) : null),
          IconButton(icon: const Icon(Icons.last_page, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24), onPressed: page < pages - 1 ? () => onPage(pages - 1) : null),
        ]),
      ]),
    );
  }
}
