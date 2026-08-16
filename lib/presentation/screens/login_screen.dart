import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web/web.dart' as web;
import '../../application/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  String? _error;

  static const _storageKey = 'remembered_email';

  @override
  void initState() {
    super.initState();
    final saved = web.window.localStorage.getItem(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      _email.text = saved;
      _remember = true;
    }
  }

  void _toggleRemember(bool? val) {
    setState(() => _remember = val ?? false);
    if (_remember && _email.text.trim().isNotEmpty) {
      web.window.localStorage.setItem(_storageKey, _email.text.trim());
    } else {
      web.window.localStorage.removeItem(_storageKey);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _login() async {
    if (!mounted) return;
    setState(() => _error = null);
    if (_formKey.currentState!.validate()) {
      try {
        final email = _email.text.trim();
        if (_remember) {
          web.window.localStorage.setItem(_storageKey, email);
        } else {
          web.window.localStorage.removeItem(_storageKey);
        }
        await ref
            .read(currentUserProvider.notifier)
            .signIn(email, _pass.text.trim());
        if (!mounted) return;
        context.go('/dashboard');
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() {
          final code = e.code;
          _error = (code == 'invalid-credential' ||
                    code == 'wrong-password' ||
                    code == 'user-not-found' ||
                    code == 'invalid-email')
              ? 'Correo o contraseña incorrectos.'
              : 'Error: ${e.message}';
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = 'Error al iniciar sesión.';
        });
      }
    }
  }

  void _resetPassword() async {
    final mail = _email.text.trim();
    if (mail.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enlace enviado a $mail')),
        );
      }
    } catch (_) {}
  }

  InputDecoration _decoration(String label, IconData icon) {
    const orange = Color(0xFFFF5E00);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: orange, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(currentUserProvider).isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_login.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              _Header(),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _LoginCard(
                      formKey: _formKey,
                      email: _email,
                      pass: _pass,
                      obscure: _obscure,
                      remember: _remember,
                      onRememberChanged: _toggleRemember,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      decoration: _decoration,
                      error: _error,
                      loading: loading,
                      onLogin: _login,
                      onResetPassword: _resetPassword,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding.top;
    final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    return Container(
      width: double.infinity,
      height: 60 + padding,
      padding: EdgeInsets.only(top: padding),
      decoration: const BoxDecoration(color: Color(0xFF11293E)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/logo_completo.png', height: 34),
          Positioned(
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  today,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFFFF5E00),
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController pass;
  final bool obscure;
  final bool remember;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onToggleObscure;
  final InputDecoration Function(String, IconData) decoration;
  final String? error;
  final bool loading;
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;

  const _LoginCard({
    required this.formKey,
    required this.email,
    required this.pass,
    required this.obscure,
    required this.remember,
    required this.onRememberChanged,
    required this.onToggleObscure,
    required this.decoration,
    required this.error,
    required this.loading,
    required this.onLogin,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF5E00);

    return Container(
      width: 380,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_icono.png', height: 56),
            const SizedBox(height: 16),
            const Text(
              'Plataforma de Gestión de ONTs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF11293E), // Azul oscuro
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Inicie sesión para continuar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: email,
              decoration: decoration('Correo electrónico', Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: pass,
              obscureText: obscure,
              decoration: decoration('Contraseña', Icons.lock_outlined)
                  .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: onToggleObscure,
                    ),
                  ),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              onFieldSubmitted: (_) => onLogin(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: remember,
                        activeColor: orange,
                        onChanged: onRememberChanged,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Recordar', style: TextStyle(fontSize: 13)),
                  ],
                ),
                TextButton(
                  onPressed: onResetPassword,
                  child: const Text(
                    '¿Olvidó contraseña?',
                    style: TextStyle(fontSize: 13, color: orange),
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Ingresar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
