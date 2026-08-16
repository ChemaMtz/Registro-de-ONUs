import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_model.dart';

/// [AuthRepository] gestiona el inicio de sesión contra Firebase Auth
/// y la recuperación de datos extendidos (roles) desde Cloud Firestore.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Correos exclusivos que pertenecen a ESTE proyecto de ONUs
  static const List<String> _allowedEmails = [
    'admin@temporal.com',
    'josemtz021020@gmail.com',
    'noc.Company@gmail.com',
    'Companysoportet1@gmail.com',
    'Companysoportet2@gmail.com',
    'Companysoportet3@gmail.com',
    'Companysoportet4@gmail.com',
    'Companysoportet5@gmail.com',
    'Companysoportet6@gmail.com',
    'Companysoportet7@gmail.com',
    'almacenCompany@gmail.com',
  ];

  static const Map<String, UserRole> _emailRoleOverrides = {
    'noc.Company@gmail.com': UserRole.admin,
    'almacenCompany@gmail.com': UserRole.bodega,
  };

  /// Observa un stream constante de FirebaseAuth para cambios de sesión de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inicio de sesión real con correo y contraseña.
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // En lugar de sobreescribir ciegamente si hay error, consultamos explícitamente el documento.
        final docRef = await _firestore.collection('users').doc(user.uid).get();

        if (!docRef.exists) {
          UserRole defaultRole = _getRoleForEmail(email);

          final newUser = UserModel(
            id: user.uid,
            email: user.email ?? email,
            role: defaultRole,
          );
          await _firestore
              .collection('users')
              .doc(newUser.id)
              .set(newUser.toJson());
          return newUser;
        } else {
          // Si el documento ya existe y el email tiene un override de rol,
          // corregimos el rol en Firestore por si estaba mal
          if (_emailRoleOverrides.containsKey(email)) {
            final correctRole = _emailRoleOverrides[email]!;
            final data = docRef.data();
            if (data != null) {
              String? currentRole = data['role']?.toString().toLowerCase();
              if (currentRole != correctRole.name) {
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .update({'role': correctRole.name});
              }
            }
          }
          return await getUserData(user.uid);
        }
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Cierra la sesión en Firebase Auth
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Busca el documento del usuario en Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id; // Sincronizamos el ID del documento

        // --- PROTECCIÓN PARA ROLES MAL FORMATEADOS ---
        if (!data.containsKey('role') || data['role'] == null) {
          data['role'] = 'soporte'; // Valor por defecto
        } else {
          String rawRole = data['role'].toString().trim().toLowerCase();
          // Por si antes se guardó erróneamente como "UserRole.soporte"
          if (rawRole.contains('.')) {
            rawRole = rawRole.split('.').last;
          }
          // Si el texto en Firebase no coincide con nuestra lista, por precaución será soporte
          if (!['admin', 'soporte', 'bodega'].contains(rawRole)) {
            rawRole = 'soporte';
          }
          data['role'] = rawRole;
        }

        // --- PROTECCIÓN PARA CORREOS NULOS O FALTANTES ---
        if (!data.containsKey('email') || data['email'] == null) {
          data['email'] = 'sin_correo@app.com';
        }

        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo usuario de Firestore: $e');
      return null; // Evitar cierre forzoso, pero el log de arriba dirá el error si hay fallo json
    }
  }

  /// Obtiene todos los usuarios de la colección `users` en Firestore
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      // Filtramos SOLAMENTE los documentos que contengan los correos de nuestro proyecto
      final projectDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        if (data['email'] == null) return false;
        return _allowedEmails.contains(data['email'].toString());
      });

      return projectDocs.map((doc) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;

          // --- PROTECCIÓN PARA ROLES MAL FORMATEADOS ---
          if (!data.containsKey('role') || data['role'] == null) {
            data['role'] = 'soporte';
          } else {
            String rawRole = data['role'].toString().trim().toLowerCase();
            if (rawRole.contains('.')) {
              rawRole = rawRole.split('.').last;
            }
            if (!['admin', 'soporte', 'bodega'].contains(rawRole)) {
              rawRole = 'soporte';
            }
            data['role'] = rawRole;
          }

          // --- PROTECCIÓN PARA CORREOS NULOS O FALTANTES ---
          if (!data.containsKey('email') || data['email'] == null) {
            data['email'] = 'sin_correo@app.com';
          }

          return UserModel.fromJson(data);
        } catch (e) {
          debugPrint('Error parseando usuario ${doc.id}: $e');
          return null;
        }
      }).whereType<UserModel>().toList();
    } catch (e) {
      debugPrint('Error al obtener todos los usuarios: $e');
      return [];
    }
  }

  /// Modifica el campo `role` de un usuario en la DB real.
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole.name,
      });
    } catch (e) {
      throw Exception('No se pudo actualizar el rol: $e');
    }
  }

  /// Determina el rol que corresponde a un email según overrides o palabras clave.
  UserRole _getRoleForEmail(String email) {
    if (_emailRoleOverrides.containsKey(email)) {
      return _emailRoleOverrides[email]!;
    }
    if (email.contains('admin')) return UserRole.admin;
    if (email.contains('bodega')) return UserRole.bodega;
    return UserRole.soporte;
  }

  /// Cambia la contraseña del usuario actual
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    
    try {
      // Reautenticar
      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      
      // Actualizar
      await user.updatePassword(newPassword);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('La contraseña actual es incorrecta.');
      } else if (e.code == 'weak-password') {
        throw Exception('La nueva contraseña es muy débil.');
      }
      throw Exception('Error al cambiar contraseña: ${e.message}');
    } catch (e) {
      throw Exception('No se pudo cambiar la contraseña: $e');
    }
  }
}
