import 'package:freezed_annotation/freezed_annotation.dart';

// Archivos generados automáticamente por Freezed
part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Enum que define de forma estricta los niveles de jerarquía de los usuarios
enum UserRole {
  /// Acceso total. Puede borrar, reescribir y configurar nuevos registros libremente
  admin,

  /// Solo actualiza datos de red del cliente, estado del enlace (tx/rx) y contraseña WiFi
  soporte,

  /// Solo tiene permitido usar la pistola (lector) para escanear y subir MAC y Serial.
  bodega,
}

/// [UserModel] encapsula la información de un empleado/usuario que haya
/// iniciado sesión en la app. Sirve para revisar autorizaciones de UI y base de datos.
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    /// UUID único en FirebaseAuth
    required String id,

    /// El correo usado en el login (Sirve como identificador visual de quién hace qué)
    required String email,

    /// Jerarquía guardada expresamente asignada en la base de datos a este correo
    required UserRole role,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
