import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Proveedor base que instancia y nos permite acceder al [AuthRepository].
/// Todas las operaciones de login/logout hacia Firebase se hacen a través de él.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Proveedor reactivo (AsyncNotifier) que mantiene el estado global del [UserModel]
/// (los datos customizados del usuario como su rol).
/// Es asíncrono porque necesita consultar Firestore para traer los roles tras el login de FirebaseAuth.
final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserModel?>(() {
      return CurrentUserNotifier();
    });

/// Clase encargada de manejar la lógica de estado del usuario actual.
/// Controla la transición de estados (cargando, con datos, o error) durante operaciones de Auth.
class CurrentUserNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() async {
    // Escuchamos a FirebaseAuth para mantener estados logueados incluso al recargar la app
    final authRepository = ref.read(authRepositoryProvider);
    final userChanges = await authRepository.authStateChanges.first;

    if (userChanges != null) {
      return await authRepository.getUserData(userChanges.uid);
    }

    return null;
  }

  /// Obtiene los datos extendidos del usuario (como su rol) desde Firestore usando su [uid] de autenticación.
  Future<void> fetchUserData(String uid) async {
    state = const AsyncValue.loading(); // Cambia el estado a "Cargando"
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.getUserData(uid);
      state = AsyncValue.data(
        user,
      ); // Guarda los datos y avisa a la UI que ya terminó
    } catch (e, st) {
      state = AsyncValue.error(
        e,
        st,
      ); // Si falla, guarda el error para que la UI lo muestre
    }
  }

  /// Realiza el inicio de sesión con correo y contraseña.
  /// Llama al repositorio para autenticar y luego actualiza automáticamente este estado global.
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signInWithEmail(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
      rethrow;
    }
  }

  /// Cierra la sesión en Firebase y borra los datos del usuario en la memoria local marcando el state en null.
  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
    state = const AsyncValue.data(null);
  }

  /// Cambia la contraseña
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.changePassword(currentPassword, newPassword);
  }
}

/// Proveedor para mantener la lista de todos los usuarios registrados (Solo Admin)
final allUsersProvider = FutureProvider.autoDispose<List<UserModel>>((
  ref,
) async {
  final authRepository = ref.read(authRepositoryProvider);
  return authRepository.getAllUsers();
});
