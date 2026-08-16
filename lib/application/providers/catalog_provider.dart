import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../domain/models/catalog_model.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

final catalogsStreamProvider = StreamProvider<CatalogModel>((ref) {
  return ref.watch(catalogRepositoryProvider).getCatalogs();
});

final catalogsConfigStreamProvider = StreamProvider<CatalogModel>((ref) {
  return ref.watch(catalogRepositoryProvider).getCatalogs(mergeOnuValues: false);
});
