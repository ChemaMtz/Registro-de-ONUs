import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/catalog_model.dart';

class CatalogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'onus';
  final String _docId = '---config_catalogs---';

  // Cache de localidades y NAPs únicos (se refresca con cada consulta explícita)
  Set<String> _cachedLocalidades = {};
  Set<String> _cachedNaps = {};

  /// Obtiene el catálogo. Si mergeOnuValues es true, fusiona las zonas
  /// y NAPs con los valores reales extraídos de las ONUs.
  Stream<CatalogModel> getCatalogs({bool mergeOnuValues = true}) {
    if (mergeOnuValues) {
      // Al iniciar el stream, refrescar las localidades y NAPs reales
      _refreshFromOnus();
    }

    return _firestore
        .collection(_collection)
        .doc(_docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        final defaultZonas = mergeOnuValues
            ? _mergeZonas(['Actopan', 'Huichapan'])
            : ['Actopan', 'Huichapan'];
        return CatalogModel(
          zonas: defaultZonas,
          modelos: ['Huawei V5', 'Huawei V5V3', 'Skyworth', 'Nokia', 'Ping Com'],
          tecnicos: ['Josmar', 'Luis'],
          soportes: ['Pablo', 'Kevin'],
          naps: mergeOnuValues ? _mergeNaps([]) : [],
        );
      }
      final catalog = CatalogModel.fromJson(doc.data()!);
      if (!mergeOnuValues) return catalog;
      return catalog.copyWith(
        zonas: _mergeZonas(catalog.zonas),
        naps: _mergeNaps(catalog.naps),
      );
    });
  }

  /// Fusiona las zonas del catálogo con las localidades reales de los ONUs.
  List<String> _mergeZonas(List<String> catalogZonas) {
    final merged = <String>{...catalogZonas, ..._cachedLocalidades}.toList();
    merged.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return merged;
  }

  /// Fusiona los NAPs del catálogo con los NAPs reales de los ONUs.
  List<String> _mergeNaps(List<String> catalogNaps) {
    final merged = <String>{...catalogNaps, ..._cachedNaps}.toList();
    merged.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return merged;
  }

  /// Refresca la caché de localidades y NAPs consultando la colección de ONUs.
  /// Usa limit() grande para reducir iteraciones, pero aún descarga todos los docs.
  /// Para optimizar más, considera mantener las localidades/NAPs en el documento de catálogos.
  Future<void> _refreshFromOnus() async {
    try {
      final localidades = <String>{};
      final naps = <String>{};
      DocumentSnapshot? lastDoc;

      while (true) {
        var query = _firestore
            .collection(_collection)
            .limit(1000);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();
        if (snapshot.docs.isEmpty) break;

        for (final doc in snapshot.docs) {
          if (doc.id == _docId) continue;
          final data = doc.data();
          final loc = (data['localidad'] ?? '').toString();
          final nap = (data['nap'] ?? '').toString();
          if (loc.isNotEmpty) localidades.add(loc);
          if (nap.isNotEmpty && nap != 'N/A') naps.add(nap);
        }

        lastDoc = snapshot.docs.last;
        if (snapshot.docs.length < 1000) break;
      }

      _cachedLocalidades = localidades;
      _cachedNaps = naps;
    } catch (_) {}
  }

  /// Actualiza una lista específica del catálogo.
  Future<void> updateCatalogList(String field, List<String> newList) async {
    try {
      await _firestore.collection(_collection).doc(_docId).set({
        field: newList,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al actualizar catálogo $field: $e');
    }
  }

  /// Actualiza un mapa específico del catálogo (como prefijos).
  Future<void> updateCatalogMap(String field, Map<String, dynamic> newMap) async {
    try {
      await _firestore.collection(_collection).doc(_docId).set({
        field: newMap,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al actualizar mapa $field: $e');
    }
  }

  /// Registra una acción en el historial de logs del documento de catálogos.
  Future<void> logCatalogAction(String action, String description, String user) async {
    try {
      final ref = _firestore.collection(_collection).doc(_docId);
      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final logs = List<Map<String, dynamic>>.from(
          (doc.data()?['historial_logs'] as List<dynamic>?) ?? [],
        );
        logs.insert(0, {
          'action': action,
          'description': description,
          'user': user,
          'date': DateTime.now().toIso8601String(),
        });
        tx.set(ref, {'historial_logs': logs}, SetOptions(merge: true));
      });
    } catch (e) {
      // No lanzamos excepción para no interrumpir la operación principal
    }
  }
}
