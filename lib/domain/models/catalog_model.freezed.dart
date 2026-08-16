// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogModel {

 List<String> get zonas; List<String> get modelos; List<String> get tecnicos; List<String> get soportes; List<String> get naps; Map<String, String> get prefijos;
/// Create a copy of CatalogModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogModelCopyWith<CatalogModel> get copyWith => _$CatalogModelCopyWithImpl<CatalogModel>(this as CatalogModel, _$identity);

  /// Serializes this CatalogModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogModel&&const DeepCollectionEquality().equals(other.zonas, zonas)&&const DeepCollectionEquality().equals(other.modelos, modelos)&&const DeepCollectionEquality().equals(other.tecnicos, tecnicos)&&const DeepCollectionEquality().equals(other.soportes, soportes)&&const DeepCollectionEquality().equals(other.naps, naps)&&const DeepCollectionEquality().equals(other.prefijos, prefijos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(zonas),const DeepCollectionEquality().hash(modelos),const DeepCollectionEquality().hash(tecnicos),const DeepCollectionEquality().hash(soportes),const DeepCollectionEquality().hash(naps),const DeepCollectionEquality().hash(prefijos));

@override
String toString() {
  return 'CatalogModel(zonas: $zonas, modelos: $modelos, tecnicos: $tecnicos, soportes: $soportes, naps: $naps, prefijos: $prefijos)';
}


}

/// @nodoc
abstract mixin class $CatalogModelCopyWith<$Res>  {
  factory $CatalogModelCopyWith(CatalogModel value, $Res Function(CatalogModel) _then) = _$CatalogModelCopyWithImpl;
@useResult
$Res call({
 List<String> zonas, List<String> modelos, List<String> tecnicos, List<String> soportes, List<String> naps, Map<String, String> prefijos
});




}
/// @nodoc
class _$CatalogModelCopyWithImpl<$Res>
    implements $CatalogModelCopyWith<$Res> {
  _$CatalogModelCopyWithImpl(this._self, this._then);

  final CatalogModel _self;
  final $Res Function(CatalogModel) _then;

/// Create a copy of CatalogModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zonas = null,Object? modelos = null,Object? tecnicos = null,Object? soportes = null,Object? naps = null,Object? prefijos = null,}) {
  return _then(_self.copyWith(
zonas: null == zonas ? _self.zonas : zonas // ignore: cast_nullable_to_non_nullable
as List<String>,modelos: null == modelos ? _self.modelos : modelos // ignore: cast_nullable_to_non_nullable
as List<String>,tecnicos: null == tecnicos ? _self.tecnicos : tecnicos // ignore: cast_nullable_to_non_nullable
as List<String>,soportes: null == soportes ? _self.soportes : soportes // ignore: cast_nullable_to_non_nullable
as List<String>,naps: null == naps ? _self.naps : naps // ignore: cast_nullable_to_non_nullable
as List<String>,prefijos: null == prefijos ? _self.prefijos : prefijos // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogModel].
extension CatalogModelPatterns on CatalogModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogModel value)  $default,){
final _that = this;
switch (_that) {
case _CatalogModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogModel value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> zonas,  List<String> modelos,  List<String> tecnicos,  List<String> soportes,  List<String> naps,  Map<String, String> prefijos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogModel() when $default != null:
return $default(_that.zonas,_that.modelos,_that.tecnicos,_that.soportes,_that.naps,_that.prefijos);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> zonas,  List<String> modelos,  List<String> tecnicos,  List<String> soportes,  List<String> naps,  Map<String, String> prefijos)  $default,) {final _that = this;
switch (_that) {
case _CatalogModel():
return $default(_that.zonas,_that.modelos,_that.tecnicos,_that.soportes,_that.naps,_that.prefijos);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> zonas,  List<String> modelos,  List<String> tecnicos,  List<String> soportes,  List<String> naps,  Map<String, String> prefijos)?  $default,) {final _that = this;
switch (_that) {
case _CatalogModel() when $default != null:
return $default(_that.zonas,_that.modelos,_that.tecnicos,_that.soportes,_that.naps,_that.prefijos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogModel implements CatalogModel {
  const _CatalogModel({final  List<String> zonas = const [], final  List<String> modelos = const [], final  List<String> tecnicos = const [], final  List<String> soportes = const [], final  List<String> naps = const [], final  Map<String, String> prefijos = const {}}): _zonas = zonas,_modelos = modelos,_tecnicos = tecnicos,_soportes = soportes,_naps = naps,_prefijos = prefijos;
  factory _CatalogModel.fromJson(Map<String, dynamic> json) => _$CatalogModelFromJson(json);

 final  List<String> _zonas;
@override@JsonKey() List<String> get zonas {
  if (_zonas is EqualUnmodifiableListView) return _zonas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zonas);
}

 final  List<String> _modelos;
@override@JsonKey() List<String> get modelos {
  if (_modelos is EqualUnmodifiableListView) return _modelos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelos);
}

 final  List<String> _tecnicos;
@override@JsonKey() List<String> get tecnicos {
  if (_tecnicos is EqualUnmodifiableListView) return _tecnicos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tecnicos);
}

 final  List<String> _soportes;
@override@JsonKey() List<String> get soportes {
  if (_soportes is EqualUnmodifiableListView) return _soportes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_soportes);
}

 final  List<String> _naps;
@override@JsonKey() List<String> get naps {
  if (_naps is EqualUnmodifiableListView) return _naps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_naps);
}

 final  Map<String, String> _prefijos;
@override@JsonKey() Map<String, String> get prefijos {
  if (_prefijos is EqualUnmodifiableMapView) return _prefijos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_prefijos);
}


/// Create a copy of CatalogModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogModelCopyWith<_CatalogModel> get copyWith => __$CatalogModelCopyWithImpl<_CatalogModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogModel&&const DeepCollectionEquality().equals(other._zonas, _zonas)&&const DeepCollectionEquality().equals(other._modelos, _modelos)&&const DeepCollectionEquality().equals(other._tecnicos, _tecnicos)&&const DeepCollectionEquality().equals(other._soportes, _soportes)&&const DeepCollectionEquality().equals(other._naps, _naps)&&const DeepCollectionEquality().equals(other._prefijos, _prefijos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_zonas),const DeepCollectionEquality().hash(_modelos),const DeepCollectionEquality().hash(_tecnicos),const DeepCollectionEquality().hash(_soportes),const DeepCollectionEquality().hash(_naps),const DeepCollectionEquality().hash(_prefijos));

@override
String toString() {
  return 'CatalogModel(zonas: $zonas, modelos: $modelos, tecnicos: $tecnicos, soportes: $soportes, naps: $naps, prefijos: $prefijos)';
}


}

/// @nodoc
abstract mixin class _$CatalogModelCopyWith<$Res> implements $CatalogModelCopyWith<$Res> {
  factory _$CatalogModelCopyWith(_CatalogModel value, $Res Function(_CatalogModel) _then) = __$CatalogModelCopyWithImpl;
@override @useResult
$Res call({
 List<String> zonas, List<String> modelos, List<String> tecnicos, List<String> soportes, List<String> naps, Map<String, String> prefijos
});




}
/// @nodoc
class __$CatalogModelCopyWithImpl<$Res>
    implements _$CatalogModelCopyWith<$Res> {
  __$CatalogModelCopyWithImpl(this._self, this._then);

  final _CatalogModel _self;
  final $Res Function(_CatalogModel) _then;

/// Create a copy of CatalogModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zonas = null,Object? modelos = null,Object? tecnicos = null,Object? soportes = null,Object? naps = null,Object? prefijos = null,}) {
  return _then(_CatalogModel(
zonas: null == zonas ? _self._zonas : zonas // ignore: cast_nullable_to_non_nullable
as List<String>,modelos: null == modelos ? _self._modelos : modelos // ignore: cast_nullable_to_non_nullable
as List<String>,tecnicos: null == tecnicos ? _self._tecnicos : tecnicos // ignore: cast_nullable_to_non_nullable
as List<String>,soportes: null == soportes ? _self._soportes : soportes // ignore: cast_nullable_to_non_nullable
as List<String>,naps: null == naps ? _self._naps : naps // ignore: cast_nullable_to_non_nullable
as List<String>,prefijos: null == prefijos ? _self._prefijos : prefijos // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
