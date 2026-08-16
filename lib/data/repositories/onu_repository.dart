import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/onu_model.dart';
import '../../domain/models/user_model.dart';
import 'log_repository.dart';

/// [OnuRepository] se encarga de manejar toda la comunicación directa con
/// la base de datos de Firebase Firestore referente a los registros de ONTs.
class OnuRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Nombre de la colección en Firebase
  final String _collection = 'onus';

  /// Agrega un registro al historial de logs en colección global
  Future<void> addLog(String action, String description, String userEmail, {String? onuId}) async {
    if (onuId == null || onuId.isEmpty) return;
    try {
      await LogRepository().addLog(onuId, action, description, userEmail);
    } catch (e) {
      debugPrint('Error saving log to ONU $onuId: $e');
    }
  }

  /// Obtiene un Stream (flujo de datos en tiempo real) con la lista de todas las ONTs.
  /// Cualquier cambio en la base de datos actualizará la app automáticamente.
  /// NOTA: Este método descarga TODOS los documentos. Usa getOnusPaginated() para mejor rendimiento.
  Stream<List<OnuModel>> getOnus() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != '---config_catalogs---')
          .map((doc) {
        final data = doc.data();
        return _parseOnuDoc(doc.id, data);
      }).toList();
    });
  }

  /// Obtiene ONUs paginadas (20 por defecto). Usa getDocs() en lugar de snapshots().
  /// Ahorra ~4980 lecturas por carga al traer solo los documentos visibles.
  Future<List<OnuModel>> getOnusPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(_collection)
        .orderBy('cliente_nombre')
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return _parseOnuDoc(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Busca ONUs por texto con paginación. Filtra en servidor cuando es posible.
  Future<List<OnuModel>> searchOnusPaginated({
    required String searchText,
    int limit = 50,
  }) async {
    if (searchText.isEmpty) return [];

    final searchLower = searchText.toLowerCase().trim();
    
    // Si es un ID numérico, buscar directamente por documento
    final asId = int.tryParse(searchLower);
    if (asId != null) {
      final doc = await _firestore.collection(_collection).doc(searchText).get();
      if (doc.exists) {
        return [_parseOnuDoc(doc.id, doc.data()!)];
      }
    }

    // Buscar por campos indexados (localidad, nap, modelo_ont)
    final results = <OnuModel>[];
    
    // Buscar por localidad
    final locQuery = await _firestore
        .collection(_collection)
        .where('localidad', isGreaterThanOrEqualTo: searchText)
        .where('localidad', isLessThanOrEqualTo: '$searchText\uf8ff')
        .limit(limit)
        .get();
    
    for (final doc in locQuery.docs) {
      if (doc.id != '---config_catalogs---') {
        results.add(_parseOnuDoc(doc.id, doc.data()));
      }
    }

    // Si no hay suficientes resultados, buscar por NAP
    if (results.length < limit) {
      final napQuery = await _firestore
          .collection(_collection)
          .where('nap', isGreaterThanOrEqualTo: searchText)
          .where('nap', isLessThanOrEqualTo: '$searchText\uf8ff')
          .limit(limit - results.length)
          .get();
      
      for (final doc in napQuery.docs) {
        if (doc.id != '---config_catalogs---' && !results.any((r) => r.id == doc.id)) {
          results.add(_parseOnuDoc(doc.id, doc.data()));
        }
      }
    }

    return results;
  }

  /// Obtiene el conteo total de ONUs sin descargar documentos.
  Future<int> getOnuCount() async {
    final snapshot = await _firestore.collection(_collection).count().get();
    return snapshot.count ?? 0;
  }

  /// Parsea un documento de Firestore a OnuModel con valores por defecto seguros
  OnuModel _parseOnuDoc(String docId, Map<String, dynamic> data) {
    data['id'] = docId;
    data['excel_id'] = data['excel_id'] ?? '';
    data['numero_serial'] = data['numero_serial'] ?? '';
    data['mac'] = data['mac'] ?? '';
    data['ssid'] = data['ssid'] ?? '';
    data['password'] = data['password'] ?? '';
    data['cliente_nombre'] = data['cliente_nombre'] ?? '';
    data['localidad'] = data['localidad'] ?? '';
    data['nap'] = data['nap'] ?? 'N/A';
    data['etiqueta'] = data['etiqueta'] ?? '';
    data['modelo_ont'] = data['modelo_ont'] ?? '';
    data['tipo_instalacion'] = data['tipo_instalacion'] ?? '';
    data['estado'] = data['estado'] ?? 'Libre';
    data['tecnico_instalador'] = data['tecnico_instalador'] ?? '';
    data['soporte_provision'] = data['soporte_provision'] ?? '';
    data['created_by'] = data['created_by'];
    data['updated_by'] = data['updated_by'];
    data['tx'] = (data['tx'] ?? 0.0).toDouble();
    data['rx'] = (data['rx'] ?? 0.0).toDouble();

    try {
      return OnuModel.fromJson(data);
    } catch (e) {
      debugPrint('Error parsing document $docId: $e');
      return OnuModel(
        id: docId,
        excelId: '',
        numeroSerial: 'ERROR',
        mac: 'ERROR',
        ssid: '',
        password: '',
        clienteNombre: 'Error leyendo datos',
        localidad: '',
        nap: '',
        etiqueta: '',
        modeloOnt: '',
        tx: 0.0,
        rx: 0.0,
        tipoInstalacion: '',
        estado: 'Libre',
        tecnicoInstalador: '',
        soporteProvision: '',
      );
    }
  }

  /// Crea un nuevo registro de ONT en Firebase.
  /// Recibe el [OnuModel] a guardar y el [UserModel] para dejar el registro de quién lo creó.
  Future<void> createOnu(OnuModel onu, UserModel user) async {
    try {
      final data = onu.toJson();
      data.remove(
        'id',
      ); // Removemos el ID del cuerpo porque será la clave primaria del documento

      // Dejamos un registro de auditoría: quién creó y actualizó el documento por primera vez
      data['created_by'] = user.email;
      data['updated_by'] = user.email;

      if (onu.id != null && onu.id!.isNotEmpty) {
        await _firestore.collection(_collection).doc(onu.id).set(data);
        await addLog('CREAR ONU', 'Cliente: ${onu.clienteNombre} | ID: ${onu.excelId ?? onu.id}', user.email, onuId: onu.id);
      } else {
        final docRef = await _firestore.collection(_collection).add(data);
        await addLog('CREAR ONU', 'Cliente: ${onu.clienteNombre} | ID: ${onu.excelId ?? docRef.id}', user.email, onuId: docRef.id);
      }
    } catch (e) {
      throw Exception('Error al crear ONU: $e');
    }
  }

  /// Importa múltiples ONUs desde un archivo Excel validado.
  /// Usa lotes de 400 documentos para respetar el límite de Firestore.
  Future<ImportResult> importOnusFromExcel(List<OnuModel> onus, UserModel user) async {
    int successCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    const batchSize = 400;
    for (int i = 0; i < onus.length; i += batchSize) {
      final batch = _firestore.batch();
      final chunk = onus.sublist(i, (i + batchSize).clamp(0, onus.length));

      for (final onu in chunk) {
        try {
          final data = onu.toJson();
          data.remove('id');
          data['created_by'] = user.email;
          data['updated_by'] = user.email;

          String docId;
          if (onu.id != null && onu.id!.isNotEmpty) {
            docId = onu.id!;
          } else if (onu.mac.isNotEmpty && onu.mac != 'N/A') {
            docId = onu.mac.replaceAll(':', '').toUpperCase();
          } else {
            docId = _firestore.collection(_collection).doc().id;
          }

          final docRef = _firestore.collection(_collection).doc(docId);
          batch.set(docRef, data, SetOptions(merge: true));
          successCount++;
        } catch (e) {
          errorCount++;
          errors.add('Error en registro ${onu.mac}: $e');
        }
      }

      try {
        await batch.commit();
        
        // Registrar logs en subcolección después de importar
        for (final onu in chunk) {
          final docId = onu.id ?? onu.mac.replaceAll(':', '').toUpperCase();
          await addLog(
            'IMPORTAR EXCEL',
            'Registro importado masivamente desde Excel',
            user.email,
            onuId: docId,
          );
        }
      } catch (e) {
        errorCount += chunk.length;
        errors.add('Error en lote ${i ~/ batchSize + 1}: $e');
      }
    }

    return ImportResult(
      successCount: successCount,
      errorCount: errorCount,
      errors: errors,
    );
  }

  /// Elimina múltiples ONUs en lote (batch delete)
  Future<int> batchDeleteOnus(List<String> ids, UserModel user) async {
    int deleted = 0;
    const batchSize = 500;

    for (int i = 0; i < ids.length; i += batchSize) {
      final batch = _firestore.batch();
      final chunk = ids.sublist(i, (i + batchSize).clamp(0, ids.length));

      for (final id in chunk) {
        batch.delete(_firestore.collection(_collection).doc(id));
      }

      await batch.commit();
      deleted += chunk.length;
    }

    return deleted;
  }

  /// Elimina una sola ONU
  Future<void> deleteOnu(String id, UserModel user) async {
    await _firestore.collection(_collection).doc(id).delete();
    await addLog('ELIMINAR ONU', 'Se eliminó la ONU con ID: $id', user.email, onuId: id);
  }

  /// Actualiza un registro existente y controla qué puede guardar cada rol.
  Future<void> updateOnu(String id, OnuModel onu, UserModel user) async {
    try {
      final userRole = user.role;
      final Map<String, dynamic> dataToUpdate = {};

      // Registramos qué correo realizó este cambio
      dataToUpdate['updated_by'] = user.email;

      if (userRole == UserRole.admin) {
        // ROL ADMIN: Tiene permisos para sobreescribir toda la información
        dataToUpdate.addAll(onu.toJson());
        dataToUpdate.remove('id');
      } else if (userRole == UserRole.bodega) {
        // ROL BODEGA: Solo tiene permitido editar los campos físicos (Serial y MAC)
        final fullData = onu.toJson();
        for (var field in ['numero_serial', 'mac']) {
          if (fullData.containsKey(field)) {
            dataToUpdate[field] = fullData[field];
          }
        }
      } else {
        // ROL SOPORTE / TECNICO: Puede actualizar métricas, asignaciones de técnico y la situación local del equipo
        final fullData = onu.toJson();
        final allowedFields = [
          'tx',
          'rx',
          'cliente_nombre',
          'localidad',
          'nap',
          'etiqueta',
          'modelo_ont',
          'tecnico_instalador',
          'soporte_provision',
        ];

        for (var field in allowedFields) {
          if (fullData.containsKey(field)) {
            dataToUpdate[field] = fullData[field];
          }
        }
      }

      // Si el rol es admin y decidieron cambiar la clave única (ID del documento) a uno nuevo:
      if (userRole == UserRole.admin &&
          onu.id != null &&
          onu.id!.isNotEmpty &&
          onu.id != id) {
        // Para cambiar un ID en Firestore, hay que clonar el documento antiguo al nuevo y luego borrar el antiguo
        final snapshot = await _firestore.collection(_collection).doc(id).get();
        if (snapshot.exists) {
          final newData = snapshot.data()!;
          newData.addAll(dataToUpdate);
          newData.remove('id');
          await _firestore.collection(_collection).doc(onu.id).set(newData);
          await _firestore.collection(_collection).doc(id).delete();
        }
        return;
      }

      // Obtenemos los datos antiguos para saber exactamente qué cambió
      final snapshot = await _firestore.collection(_collection).doc(id).get();
      String clienteInfo = '';
      String description = 'Se actualizaron datos';
      
      if (snapshot.exists) {
        final oldData = snapshot.data()!;
        clienteInfo = ' | Cliente: ${oldData['cliente_nombre'] ?? 'Sin nombre'}';
        final onuExcelId = oldData['excel_id'] ?? id;
        clienteInfo += ' | ID: $onuExcelId';
        
        final changedFields = <String>[];
        
        dataToUpdate.forEach((key, value) {
          if (key != 'updated_by' && key != 'historial_logs' && oldData[key] != value) {
            changedFields.add(key);
          }
        });
        
        if (changedFields.isNotEmpty) {
          final fieldNames = changedFields.map((f) {
            switch (f) {
              case 'cliente_nombre': return 'Cliente';
              case 'localidad': return 'Localidad';
              case 'nap': return 'NAP';
              case 'estado': return 'Estado';
              case 'numero_serial': return 'Serial';
              case 'mac': return 'MAC';
              case 'ssid': return 'SSID';
              case 'password': return 'Password';
              case 'modelo_ont': return 'Modelo';
              case 'tx': return 'TX';
              case 'rx': return 'RX';
              case 'etiqueta': return 'Etiqueta';
              case 'tipo_instalacion': return 'Tipo Inst.';
              case 'tecnico_instalador': return 'Técnico';
              case 'soporte_provision': return 'Soporte';
              default: return f;
            }
          }).join(', ');
          description = 'Editó: $fieldNames';
        }
      }

      await _firestore.collection(_collection).doc(id).update(dataToUpdate);
      await addLog('ACTUALIZAR ONU', '$description$clienteInfo', user.email, onuId: id);
    } catch (e) {
      throw Exception('Error al actualizar ONU: $e');
    }
  }
}

class ImportResult {
  final int successCount;
  final int errorCount;
  final List<String> errors;

  ImportResult({
    required this.successCount,
    required this.errorCount,
    required this.errors,
  });
}
