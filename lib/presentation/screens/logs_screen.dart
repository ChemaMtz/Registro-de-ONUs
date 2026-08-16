import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/auth_provider.dart';
import '../../application/providers/logs_provider.dart';
import '../../domain/models/user_model.dart';
import '../widgets/app_shell.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);
const _BG = Color(0xFFF2F2F2);

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final isAdmin = user?.role == UserRole.admin;
    final narrow = MediaQuery.of(context).size.width < 700;
    
    // Solo permitimos ver logs a admins (u ocultamos si es necesario, pero como lo pides, asumimos admin)
    // if (!isAdmin) return const Scaffold(body: Center(child: Text('Acceso Denegado')));

    final logsAsync = ref.watch(logsStreamProvider);

    return Scaffold(
      backgroundColor: _BG,
      drawer: narrow
          ? Drawer(
              child: AppSidebar(
                isAdmin: isAdmin,
                active: 6, // 6 corresponde a Logs
              ),
            )
          : null,
      body: Column(
        children: [
          AppTopBar(user: user, ref: ref),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!narrow)
                  AppSidebar(
                    isAdmin: isAdmin,
                    active: 6,
                  ),
                Expanded(
                  child: logsAsync.when(
                    data: (logs) {
                      return _LogsContent(logs: logs);
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: _O),
                    ),
                    error: (err, stack) => Center(
                      child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
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
}

class _LogsContent extends StatefulWidget {
  final List<LogEntry> logs;

  const _LogsContent({required this.logs});

  @override
  State<_LogsContent> createState() => _LogsContentState();
}

class _LogsContentState extends State<_LogsContent> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  int _page = 0;
  int _perPage = 10;
  final _pageCtrl = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = val;
        _page = 0;
      });
    });
  }

  List<LogEntry> get _filteredLogs {
    if (_searchQuery.isEmpty) return widget.logs;
    final q = _searchQuery.toLowerCase();
    return widget.logs.where((l) {
      return l.action.toLowerCase().contains(q) ||
             l.description.toLowerCase().contains(q) ||
             l.user.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay registros de actividad',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredLogs;
    final totalPages = (filtered.length / _perPage).ceil();
    if (_page >= totalPages && totalPages > 0) {
      _page = totalPages - 1;
    }
    
    final startIndex = _page * _perPage;
    final endIndex = (startIndex + _perPage).clamp(0, filtered.length);
    final paginatedLogs = filtered.sublist(startIndex, endIndex);

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
              
              // Barra de Búsqueda
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar por acción, usuario, número serial...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {
                                _searchQuery = '';
                                _page = 0;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron resultados para "$_searchQuery"',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paginatedLogs.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final log = paginatedLogs[index];
                        final dateStr = log.timestamp != null
                            ? '${log.timestamp!.day.toString().padLeft(2, '0')}/${log.timestamp!.month.toString().padLeft(2, '0')}/${log.timestamp!.year} ${log.timestamp!.hour.toString().padLeft(2, '0')}:${log.timestamp!.minute.toString().padLeft(2, '0')}'
                            : 'Fecha desconocida';

                        Color iconColor = _N;
                        IconData icon = Icons.info_outline;
                        String actionLabel = log.action;
                        
                        final act = log.action.toLowerCase();
                        if (act.contains('crear')) {
                          iconColor = Colors.green.shade600;
                          icon = Icons.add_circle_outline;
                          actionLabel = 'ONU Creada';
                        } else if (act.contains('actualizar') || act.contains('editar')) {
                          iconColor = Colors.blue.shade600;
                          icon = Icons.edit_outlined;
                          actionLabel = 'ONU Editada';
                        } else if (act.contains('eliminar')) {
                          iconColor = Colors.red.shade600;
                          icon = Icons.delete_outline;
                          actionLabel = 'ONU Eliminada';
                        } else if (act.contains('importar')) {
                          iconColor = Colors.purple.shade600;
                          icon = Icons.upload_file;
                          actionLabel = 'Importación';
                        } else if (act.contains('catálogo')) {
                          iconColor = Colors.orange.shade700;
                          icon = Icons.list_alt;
                          actionLabel = 'Catálogo';
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: iconColor, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            actionLabel,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _N),
                                          ),
                                        ),
                                        Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      log.description,
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 12, color: Colors.grey.shade400),
                                        const SizedBox(width: 4),
                                        Text(log.user, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                        if (log.onuId.isNotEmpty) ...[
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: _N.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(4)),
                                            child: Text('ID: ${log.onuId}', style: TextStyle(fontSize: 10, color: _N.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Paginación
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Filas por página:', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _perPage,
                            isDense: true,
                            underline: const SizedBox(),
                            items: [10, 20, 50, 100].map((v) => DropdownMenuItem(value: v, child: Text('$v', style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _perPage = v;
                                  _page = 0;
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          Text('${startIndex + 1} - $endIndex de ${filtered.length}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _page > 0 ? () => setState(() => _page--) : null,
                          ),
                          Text('Página ${_page + 1} de ${totalPages == 0 ? 1 : totalPages}', style: const TextStyle(fontSize: 13)),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
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
              Icons.receipt_long_outlined,
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
                  'Registro de Actividades',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Historial de creación, edición y cambios en el sistema',
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
