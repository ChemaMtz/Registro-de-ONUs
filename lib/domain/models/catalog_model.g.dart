// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatalogModel _$CatalogModelFromJson(
  Map<String, dynamic> json,
) => _CatalogModel(
  zonas:
      (json['zonas'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  modelos:
      (json['modelos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  tecnicos:
      (json['tecnicos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  soportes:
      (json['soportes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  naps:
      (json['naps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  prefijos:
      (json['prefijos'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$CatalogModelToJson(_CatalogModel instance) =>
    <String, dynamic>{
      'zonas': instance.zonas,
      'modelos': instance.modelos,
      'tecnicos': instance.tecnicos,
      'soportes': instance.soportes,
      'naps': instance.naps,
      'prefijos': instance.prefijos,
    };
