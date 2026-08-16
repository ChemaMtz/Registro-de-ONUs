import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/log_repository.dart';

class LogEntry {
  final String id;
  final String onuId;
  final String action;
  final String description;
  final String user;
  final DateTime? timestamp;

  LogEntry({
    required this.id,
    required this.onuId,
    required this.action,
    required this.description,
    required this.user,
    this.timestamp,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] ?? '',
      onuId: json['onuId'] ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      user: json['user'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}

final logRepositoryProvider = Provider<LogRepository>((ref) {
  return LogRepository();
});

/// Provider que obtiene los últimos 100 logs de la subcolección
/// Usa collectionGroup - consulta eficiente sin descargar ONUs
final logsStreamProvider = StreamProvider<List<LogEntry>>((ref) {
  final repository = ref.watch(logRepositoryProvider);
  return repository.getAllRecentLogs(limit: 100).map((logsList) {
    return logsList.map((log) => LogEntry.fromJson(log)).toList();
  });
});
