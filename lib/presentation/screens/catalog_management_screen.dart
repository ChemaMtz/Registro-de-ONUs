import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/catalog_provider.dart';
import '../../domain/models/user_model.dart';
import '../widgets/app_shell.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);
const _BG = Color(0xFFF2F2F2);

class CatalogManagementScreen extends ConsumerWidget {
  const CatalogManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final isAdmin = user?.role == UserRole.admin;
    final catalogsAsync = ref.watch(catalogsConfigStreamProvider);

    return Scaffold(
      backgroundColor: _BG,
      body: Column(
        children: [
          AppTopBar(user: user, ref: ref),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSidebar(isAdmin: isAdmin, active: 5),
                Expanded(
                  child: catalogsAsync.when(
                    data: (catalogs) {
                      final cards = [
                        _CatalogCardData(
                          title: 'Zonas / Localidades',
                          icon: Icons.location_on_outlined,
                          items: catalogs.zonas,
                          fieldKey: 'zonas',
                          prefijos: catalogs.prefijos,
                        ),
                        _CatalogCardData(
                          title: 'Modelos de ONT',
                          icon: Icons.router_outlined,
                          items: catalogs.modelos,
                          fieldKey: 'modelos',
                        ),
                        _CatalogCardData(
                          title: 'Técnicos Instaladores',
                          icon: Icons.handyman_outlined,
                          items: catalogs.tecnicos,
                          fieldKey: 'tecnicos',
                        ),
                        _CatalogCardData(
                          title: 'Personal de Soporte',
                          icon: Icons.headset_mic_outlined,
                          items: catalogs.soportes,
                          fieldKey: 'soportes',
                        ),
                        _CatalogCardData(
                          title: 'NAPs',
                          icon: Icons.cable,
                          items: catalogs.naps,
                          fieldKey: 'naps',
                        ),
                      ];

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 1060),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Banner(),
                                const SizedBox(height: 24),
                                _buildGrid(cards),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const _LoadingSkeleton(),
                    error: (e, _) => _ErrorState(error: e.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_CatalogCardData> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        if (!isWide) {
          return Column(
            children: cards.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CatalogCard(data: c),
            )).toList(),
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < cards.length; i += 2) {
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _CatalogCard(data: cards[i])),
                  if (i + 1 < cards.length) ...[
                    const SizedBox(width: 16),
                    Expanded(child: _CatalogCard(data: cards[i + 1])),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

// ═══════════════════════════════════════════════ CATALOG CARD DATA
class _CatalogCardData {
  final String title;
  final IconData icon;
  final List<String> items;
  final String fieldKey;
  final Map<String, String>? prefijos;
  const _CatalogCardData({
    required this.title,
    required this.icon,
    required this.items,
    required this.fieldKey,
    this.prefijos,
  });
}

// ═══════════════════════════════════════════════ BANNER
class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_N, Color(0xFF1A3D56)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.list_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Catálogos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administra zonas, modelos, técnicos y personal de soporte',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
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

// ═══════════════════════════════════════════════ CATALOG CARD
class _CatalogCard extends ConsumerStatefulWidget {
  final _CatalogCardData data;
  const _CatalogCard({required this.data});

  @override
  ConsumerState<_CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends ConsumerState<_CatalogCard> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> get _filteredItems {
    final items = widget.data.items.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (_searchQuery.isEmpty) return items;
    return items
        .where((i) => i.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _addItem() {
    final controller = TextEditingController();
    final prefijoController = TextEditingController();
    final isZonas = widget.data.fieldKey == 'zonas';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _N.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.data.icon, color: _N, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Añadir a ${widget.data.title}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: isZonas ? 'Nombre de la localidad...' : 'Escribe un nombre...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _O, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (val) => _submitNewItem(ctx, val, isZonas ? prefijoController.text : null),
            ),
            if (isZonas) ...[
              const SizedBox(height: 16),
              TextField(
                controller: prefijoController,
                decoration: InputDecoration(
                  hintText: 'Prefijo (ej. QRO-)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _O, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (val) => _submitNewItem(ctx, controller.text, val),
              ),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _submitNewItem(ctx, controller.text, isZonas ? prefijoController.text : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _N,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitNewItem(BuildContext ctx, String text, [String? prefijo]) async {
    final newItem = text.trim();
    if (newItem.isEmpty) return;
    if (widget.data.items.contains(newItem)) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('"$newItem" ya existe en la lista.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }
    final user = ref.read(currentUserProvider).value?.email ?? 'Sistema';
    final newList = [...widget.data.items, newItem];
    await ref
        .read(catalogRepositoryProvider)
        .updateCatalogList(widget.data.fieldKey, newList);

    await ref.read(catalogRepositoryProvider).logCatalogAction(
      'Catálogo > Añadir ${widget.data.title}',
      '"$newItem" añadido a ${widget.data.title}.',
      user,
    );

    if (widget.data.fieldKey == 'zonas' && prefijo != null) {
      final prefijoKey = newItem.toLowerCase().trim();
      final currentMap = widget.data.prefijos ?? {};
      final newMap = Map<String, String>.from(currentMap);
      newMap[prefijoKey] = prefijo.trim().toUpperCase();
      await ref.read(catalogRepositoryProvider).updateCatalogMap('prefijos', newMap);
    }

    if (ctx.mounted) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('"$newItem" añadido correctamente.'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmRemove(String item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Eliminar elemento',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ya no aparecerá en el menú desplegable, pero las ONUs que lo tengan asignado no se modificarán.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final user = ref.read(currentUserProvider).value?.email ?? 'Sistema';
              final newList =
                  widget.data.items.where((i) => i != item).toList();
              await ref
                  .read(catalogRepositoryProvider)
                  .updateCatalogList(widget.data.fieldKey, newList);
              await ref.read(catalogRepositoryProvider).logCatalogAction(
                'Catálogo > Eliminar ${widget.data.title}',
                '"$item" eliminado de ${widget.data.title}.',
                user,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('"$item" eliminado correctamente.'),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editItem(String oldItem) {
    final isZonas = widget.data.fieldKey == 'zonas';
    final controller = TextEditingController(text: oldItem);
    
    String initialPrefijo = '';
    if (isZonas && widget.data.prefijos != null) {
      final key = oldItem.toLowerCase().trim();
      initialPrefijo = widget.data.prefijos![key] ?? '';
    }
    final prefijoController = TextEditingController(text: initialPrefijo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _N.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.edit_outlined, color: _N, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Editar elemento',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: isZonas ? 'Nombre de la localidad...' : 'Nuevo nombre...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _O, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (val) => _submitEdit(ctx, oldItem, val, isZonas ? prefijoController.text : null),
            ),
            if (isZonas) ...[
              const SizedBox(height: 16),
              TextField(
                controller: prefijoController,
                decoration: InputDecoration(
                  hintText: 'Prefijo (ej. QRO-)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _O, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (val) => _submitEdit(ctx, oldItem, controller.text, val),
              ),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _submitEdit(ctx, oldItem, controller.text, isZonas ? prefijoController.text : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _N,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEdit(
      BuildContext ctx, String oldItem, String newText, [String? prefijo]) async {
    final newItem = newText.trim();
    if (newItem.isEmpty) {
      Navigator.pop(ctx);
      return;
    }

    final isZonas = widget.data.fieldKey == 'zonas';
    final oldKey = oldItem.toLowerCase().trim();
    String? currentPrefijo;
    if (isZonas && widget.data.prefijos != null) {
      currentPrefijo = widget.data.prefijos![oldKey];
    }
    
    final newPrefijoTrimmed = prefijo?.trim().toUpperCase();
    final isPrefijoChanged = isZonas && newPrefijoTrimmed != currentPrefijo;

    if (newItem == oldItem && !isPrefijoChanged) {
      Navigator.pop(ctx);
      return;
    }
    if (newItem != oldItem) {
      if (widget.data.items.contains(newItem)) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('"$newItem" ya existe en la lista.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
      final newList =
          widget.data.items.map((i) => i == oldItem ? newItem : i).toList();
      await ref
          .read(catalogRepositoryProvider)
          .updateCatalogList(widget.data.fieldKey, newList);
    }

    if (widget.data.fieldKey == 'zonas') {
      final oldKey = oldItem.toLowerCase().trim();
      final newKey = newItem.toLowerCase().trim();
      final currentMap = widget.data.prefijos ?? {};
      final newMap = Map<String, String>.from(currentMap);
      
      // Si cambió el nombre, eliminamos la clave vieja
      if (oldKey != newKey) {
        newMap.remove(oldKey);
      }
      
      if (prefijo != null) {
        newMap[newKey] = prefijo.trim().toUpperCase();
      }
      await ref.read(catalogRepositoryProvider).updateCatalogMap('prefijos', newMap);
    }

    // Loggear la edición
    final user = ref.read(currentUserProvider).value?.email ?? 'Sistema';
    await ref.read(catalogRepositoryProvider).logCatalogAction(
      'Catálogo > Editar ${widget.data.title}',
      '"$oldItem" → "$newItem" en ${widget.data.title}.',
      user,
    );

    if (ctx.mounted) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('"$oldItem" → "$newItem" actualizado.'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final isEmpty = widget.data.items.isEmpty;
    final filteredEmpty = filtered.isEmpty;

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _N.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.data.icon, color: _N, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.data.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _N,
                    ),
                  ),
                ),
                Text(
                  '${widget.data.items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: Material(
                    color: _O.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(17),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: _addItem,
                      child: const Icon(Icons.add, color: _O, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Search ──
            if (!isEmpty)
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon:
                      Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              size: 16, color: Colors.grey.shade400),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _O, width: 1.5),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            if (!isEmpty) const SizedBox(height: 14),

            // ── Items ──
            if (isEmpty)
              _buildEmptyState()
            else if (filteredEmpty)
              _buildNoResults()
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 260),
                  color: Colors.grey.shade50,
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            filtered.map((item) => _CatalogChip(
                                      label: item,
                                      onTap: () => _editItem(item),
                                      onDelete: () => _confirmRemove(item),
                                    )).toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            'Sin elementos registrados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Presiona + para añadir el primer elemento.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 34,
            height: 34,
            child: Material(
              color: _O.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(17),
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: _addItem,
                child: const Icon(Icons.add, color: _O, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ningún elemento coincide con "$_searchQuery".',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════ CATALOG CHIP
class _CatalogChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CatalogChip({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.only(left: 12, right: 6, top: 7, bottom: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _O,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════ ERROR STATE
class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              'Error al cargar catálogos',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════ LOADING SKELETON
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 700;
                  final card = (Widget child) => Expanded(child: child);
                  return Column(
                    children: List.generate(2, (row) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            card(_skeletonCard()),
                            if (isWide) const SizedBox(width: 16),
                            card(_skeletonCard()),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
