import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_provider.dart';
import '../../domain/models/user_model.dart';
import '../widgets/app_shell.dart';

const _N = Color(0xFF11293E);
const _O = Color(0xFFFF5E00);
const _BG = Color(0xFFF2F2F2);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(currentUserProvider.notifier).changePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contraseña actualizada correctamente.'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final isAdmin = user?.role == UserRole.admin;
    final narrow = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _BG,
      drawer: narrow
          ? Drawer(
              child: AppSidebar(
                isAdmin: isAdmin,
                active: -1, // No hay item activo en la barra lateral para Perfil
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
                    active: -1,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mi Perfil',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _N,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: _N.withValues(alpha: 0.1),
                                          child: const Icon(Icons.person, color: _N, size: 30),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user?.email ?? 'Sin correo',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: _N,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _O.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  user?.role.name.toUpperCase() ?? '',
                                                  style: const TextStyle(
                                                    color: _O,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    const Divider(),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Cambiar Contraseña',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: _N,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          _buildPasswordField(
                                            controller: _currentPasswordController,
                                            label: 'Contraseña Actual',
                                            obscure: _obscureCurrent,
                                            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildPasswordField(
                                            controller: _newPasswordController,
                                            label: 'Nueva Contraseña',
                                            obscure: _obscureNew,
                                            onToggle: () => setState(() => _obscureNew = !_obscureNew),
                                            validator: (val) {
                                              if (val == null || val.isEmpty) return 'Requerido';
                                              if (val.length < 6) return 'Mínimo 6 caracteres';
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          _buildPasswordField(
                                            controller: _confirmPasswordController,
                                            label: 'Confirmar Nueva Contraseña',
                                            obscure: _obscureConfirm,
                                            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                            validator: (val) {
                                              if (val != _newPasswordController.text) {
                                                return 'Las contraseñas no coinciden';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: _isLoading ? null : _changePassword,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _O,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Actualizar Contraseña',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator: validator ??
          (val) {
            if (val == null || val.isEmpty) return 'Requerido';
            return null;
          },
    );
  }
}
