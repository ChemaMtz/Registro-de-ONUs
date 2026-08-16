import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_model.freezed.dart';
part 'catalog_model.g.dart';

@freezed
abstract class CatalogModel with _$CatalogModel {
  const factory CatalogModel({
    @Default([]) List<String> zonas,
    @Default([]) List<String> modelos,
    @Default([]) List<String> tecnicos,
    @Default([]) List<String> soportes,
    @Default([]) List<String> naps,
    @Default({}) Map<String, String> prefijos,
  }) = _CatalogModel;

  factory CatalogModel.fromJson(Map<String, dynamic> json) =>
      _$CatalogModelFromJson(json);
}
