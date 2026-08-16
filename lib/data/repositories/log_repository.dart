import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'onus';
  final String _docId = '---config_catalogs---';
  final String _logsField = 'logs_historial';

  /// Guarda un log en el documento de catálogos (colección onus, con permisos)
  Future<void> addLog(String onuId, String action, String description, String user) async {
    try {
      final ref = _firestore.collection(_collection).doc(_docId);
      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final logs = List<Map<String, dynamic>>.from(
          (doc.data()?[_logsField] as List<dynamic>?) ?? [],
        );
        logs.insert(0, {
          'onuId': onuId,
          'action': action,
          'description': description,
          'user': user,
          'timestamp': DateTime.now().toIso8601String(),
        });
        // Mantener solo los últimos 500 logs
        if (logs.length > 500) {
          logs.removeRange(500, logs.length);
        }
        tx.set(ref, {_logsField: logs}, SetOptions(merge: true));
      });
    } catch (e) {
      debugPrint('Error saving log: $e');
    }
  }

  /// Obtiene el stream de logs desde el documento de catálogos
  Stream<List<Map<String, dynamic>>> getAllRecentLogs({int limit = 200}) {
    return _firestore
        .collection(_collection)
        .doc(_docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return [];
      final logs = List<Map<String, dynamic>>.from(
        (doc.data()?[_logsField] as List<dynamic>?) ?? [],
      );
      final limited = logs.take(limit).toList();
      return limited.map((log) {
        return {
          'id': log['onuId']?.toString() ?? '',
          'onuId': log['onuId']?.toString() ?? '',
          'action': log['action']?.toString() ?? '',
          'description': log['description']?.toString() ?? '',
          'user': log['user']?.toString() ?? '',
          'timestamp': log['timestamp'] is Timestamp
              ? (log['timestamp'] as Timestamp)
              : (log['timestamp'] != null
                  ? Timestamp.fromDate(DateTime.parse(log['timestamp'].toString()))
                  : null),
        };
      }).toList();
    });
  }
}
