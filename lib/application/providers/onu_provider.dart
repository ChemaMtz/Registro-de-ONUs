import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/onu_model.dart';
import '../../data/repositories/onu_repository.dart';
import 'auth_provider.dart';
import '../../domain/models/user_model.dart';

/// Proveedor simple que instancia y nos permite acceder al [OnuRepository].
/// De esta forma, cualquier parte de la app puede leer o escribir en la BD sin instanciar la clase múltiples veces.
final onuRepositoryProvider = Provider<OnuRepository>((ref) {
  return OnuRepository();
});

/// Proveedor tipo Stream que se suscribe a los cambios en la lista de ONTs de la base de datos.
/// Escucha constantemente `getOnus()`. Cuando la BD cambia, la UI vinculada a este provider se reconstruye automáticamente.
final onusStreamProvider = StreamProvider<List<OnuModel>>((ref) {
  final repository = ref.watch(onuRepositoryProvider);
  return repository.getOnus();
});

/// Proveedor que expone las acciones (crear, actualizar, borrar) sobre las ONTs.
/// Lo interesante aquí es que inyectamos al usuario actual para tener su rol e información
/// disponible ANTES de hacer la petición a la base de datos, validando los permisos desde la capa lógica.
final onuActionsProvider = Provider<OnuActions>((ref) {
  // Observa el repositorio
  final repository = ref.watch(onuRepositoryProvider);
  // Observa el estado actual del usuario (si está logueado o no, y sus datos)
  final currentUserState = ref.watch(currentUserProvider);

  UserModel? user;
  // Si el usuario cargó exitosamente y no es nulo, lo guardamos
  if (currentUserState is AsyncData<UserModel?> &&
      currentUserState.value != null) {
    user = currentUserState.value;
  }

  // Retorna nuestra clase controladora de acciones pasándole las dependencias necesarias
  return OnuActions(repository, user);
});

/// [OnuActions] es la clase encargada de autorizar y delegar las modificaciones
/// de cualquier registro ONT al repositorio. Sirve como un "guardia" de permisos.
class OnuActions {
  final OnuRepository _repository;
  final UserModel? _user;

  OnuActions(this._repository, this._user);

  /// Crea una nueva ONT verificando primero si el usuario actual es un Administrador.
  Future<void> createOnu(OnuModel onu) async {
    // Seguridad: Si no hay usuario logueado o NO es admin, bloquea la acción.
    if (_user == null || _user.role != UserRole.admin) {
      throw Exception(
        'Permiso denegado: Solo los administradores pueden crear ONTs.',
      );
    }
    // Delega el guardado al repositorio, enviando el objeto de usuario para la auditoría (created_by)
    await _repository.createOnu(onu, _user);
  }

  /// Actualiza una ONT existente. Verifica que al menos exista un usuario logueado.
  /// (La lógica de saber QUÉ campos puede modificar cada usuario está dentro del Repository).
  Future<void> updateOnu(String id, OnuModel onu) async {
    if (_user == null) {
      throw Exception('Usuario no autenticado.');
    }
    await _repository.updateOnu(id, onu, _user);
  }

  /// Elimina una sola ONU (admin y bodega)
  Future<void> deleteOnu(String id) async {
    if (_user == null || (_user.role != UserRole.admin && _user.role != UserRole.bodega)) {
      throw Exception('Permiso denegado.');
    }
    await _repository.deleteOnu(id, _user);
  }

  /// Elimina múltiples ONUs en lote (admin y bodega)
  Future<int> batchDeleteOnus(List<String> ids) async {
    if (_user == null || (_user.role != UserRole.admin && _user.role != UserRole.bodega)) {
      throw Exception('Permiso denegado.');
    }
    if (ids.isEmpty) return 0;
    return await _repository.batchDeleteOnus(ids, _user);
  }
}
