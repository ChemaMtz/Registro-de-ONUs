import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';
import '../../domain/models/user_model.dart';
import 'excel_import_dialog.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);
const _SD = Color(0xFF162636);

class AppTopBar extends StatelessWidget {
  final UserModel? user;
  final WidgetRef ref;
  final String? date;

  const AppTopBar({
    super.key,
    required this.user,
    required this.ref,
    this.date,
  });

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.soporte:
        return 'Soporte';
      case UserRole.bodega:
        return 'Bodega';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding.top;
    final today = date ??
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    return Container(
      height: 60 + pad,
      padding: EdgeInsets.only(top: pad),
      decoration: const BoxDecoration(color: _N),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Image.asset('assets/images/logo_completo.png', height: 30),
          const Spacer(),
          Text(today,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(width: 10),
          const Icon(Icons.workspace_premium, color: _O, size: 20),
          const SizedBox(width: 6),
          Text(
            user != null ? _roleLabel(user!.role) : '',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => context.go('/profile'),
            borderRadius: BorderRadius.circular(15),
            child: const CircleAvatar(
              radius: 15,
              backgroundColor: _O,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              ref.read(currentUserProvider.notifier).signOut();
              context.go('/');
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class AppSidebar extends ConsumerWidget {
  final bool isAdmin;
  final int active;
  final VoidCallback? onDownloadCsv;
  final List<Widget>? extraItems;

  const AppSidebar({
    super.key,
    required this.isAdmin,
    required this.active,
    this.onDownloadCsv,
    this.extraItems,
  });

  Future<void> _importExcel(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ExcelImportDialog(user: user),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Importación completada exitosamente'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final isBodega = user?.role == UserRole.bodega;
    final canImport = isAdmin || isBodega;

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: _SD,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          AppSidebarItem(Icons.dashboard, 'Dashboard', 0, active,
              () => context.go('/dashboard')),
          AppSidebarItem(Icons.list_alt_rounded, 'Lista de ONUS', 1, active,
              () => context.go('/onus')),
          if (isAdmin)
            AppSidebarItem(Icons.add_circle_outline, 'Nueva ONU', 2, active,
                () => context.go('/onu/new')),
          if (isAdmin)
            AppSidebarItem(Icons.manage_accounts, 'Panel Admin', 4, active,
                () => context.go('/admin')),
          if (isAdmin)
            AppSidebarItem(Icons.list_alt, 'Catalogos', 5, active,
                () => context.go('/admin/catalogs')),
          if (isAdmin)
            AppSidebarItem(Icons.receipt_long_outlined, 'Logs', 6, active,
                () => context.go('/admin/logs')),
          if (onDownloadCsv != null)
            AppSidebarItem(Icons.download, 'Descargar CSV', 99, active,
                onDownloadCsv!, color: Colors.green.shade400),
          if (canImport)
            AppSidebarItem(Icons.upload_file, 'Importar Excel', 98, active,
                () => _importExcel(context, ref), color: Colors.blue.shade400),
          if (extraItems != null) ...extraItems!,
          const Spacer(),
        ],
      ),
    );
  }
}

class AppSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final VoidCallback onTap;
  final Color? color;

  const AppSidebarItem(
    this.icon,
    this.label,
    this.index,
    this.selected,
    this.onTap, {
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: active ? _O.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: active ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(icon,
                    color: color ?? (active ? _O : Colors.grey.shade400),
                    size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color ?? (active ? _O : Colors.grey.shade300),
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
