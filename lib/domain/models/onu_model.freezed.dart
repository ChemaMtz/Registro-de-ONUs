// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onu_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnuModel {

/// ID único auto-generado por Firestore
 String? get id;/// ID del Excel / CSV (identificador visible al usuario)
@JsonKey(name: 'excel_id') String? get excelId;/// Identificador de inventario único físico del aparato
@JsonKey(name: 'numero_serial') String get numeroSerial;/// Dirección física de red asignada al hardware
 String get mac;/// Nombre de la red Wifi
 String get ssid;/// Contraseña actual del wifi
 String get password;/// Usado como respaldo para poder hacer comparativas o revertir cambios
@JsonKey(name: 'password_antigua') String? get passwordAntigua;/// Datos de identificación del cliente
@JsonKey(name: 'cliente_nombre') String get clienteNombre; String get localidad;/// Caja NAP de fibra a la que se engancha en la calle
 String get nap;/// Etiqueta interna de gestión de la empresa
 String get etiqueta;/// Marca y diseño del dispositivo (ej. Huawei, Nokia)
@JsonKey(name: 'modelo_ont') String get modeloOnt;/// Nivel de transmisión óptica emitido (Usualmente negativo y se mide en dBm)
 double get tx;/// Nivel de recepción (señal óptica que llega a la caja)
 double get rx;/// Si fue fibra nueva, migración de cobre, reubicación, etc.
@JsonKey(name: 'tipo_instalacion') String get tipoInstalacion;/// Estado en bodega del aparato (Libre, Asignado, Defectuoso)
@JsonKey(name: 'estado') String get estado;/// Nombres de los empleados involucrados en dejar este equipo funcional
@JsonKey(name: 'tecnico_instalador') String get tecnicoInstalador;@JsonKey(name: 'soporte_provision') String get soporteProvision;/// Auditoría de registros: guardan el email/nombre del responsable
@JsonKey(name: 'created_by') String? get createdBy;@JsonKey(name: 'updated_by') String? get updatedBy;
/// Create a copy of OnuModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnuModelCopyWith<OnuModel> get copyWith => _$OnuModelCopyWithImpl<OnuModel>(this as OnuModel, _$identity);

  /// Serializes this OnuModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnuModel&&(identical(other.id, id) || other.id == id)&&(identical(other.excelId, excelId) || other.excelId == excelId)&&(identical(other.numeroSerial, numeroSerial) || other.numeroSerial == numeroSerial)&&(identical(other.mac, mac) || other.mac == mac)&&(identical(other.ssid, ssid) || other.ssid == ssid)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordAntigua, passwordAntigua) || other.passwordAntigua == passwordAntigua)&&(identical(other.clienteNombre, clienteNombre) || other.clienteNombre == clienteNombre)&&(identical(other.localidad, localidad) || other.localidad == localidad)&&(identical(other.nap, nap) || other.nap == nap)&&(identical(other.etiqueta, etiqueta) || other.etiqueta == etiqueta)&&(identical(other.modeloOnt, modeloOnt) || other.modeloOnt == modeloOnt)&&(identical(other.tx, tx) || other.tx == tx)&&(identical(other.rx, rx) || other.rx == rx)&&(identical(other.tipoInstalacion, tipoInstalacion) || other.tipoInstalacion == tipoInstalacion)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.tecnicoInstalador, tecnicoInstalador) || other.tecnicoInstalador == tecnicoInstalador)&&(identical(other.soporteProvision, soporteProvision) || other.soporteProvision == soporteProvision)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,excelId,numeroSerial,mac,ssid,password,passwordAntigua,clienteNombre,localidad,nap,etiqueta,modeloOnt,tx,rx,tipoInstalacion,estado,tecnicoInstalador,soporteProvision,createdBy,updatedBy]);

@override
String toString() {
  return 'OnuModel(id: $id, excelId: $excelId, numeroSerial: $numeroSerial, mac: $mac, ssid: $ssid, password: $password, passwordAntigua: $passwordAntigua, clienteNombre: $clienteNombre, localidad: $localidad, nap: $nap, etiqueta: $etiqueta, modeloOnt: $modeloOnt, tx: $tx, rx: $rx, tipoInstalacion: $tipoInstalacion, estado: $estado, tecnicoInstalador: $tecnicoInstalador, soporteProvision: $soporteProvision, createdBy: $createdBy, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class $OnuModelCopyWith<$Res>  {
  factory $OnuModelCopyWith(OnuModel value, $Res Function(OnuModel) _then) = _$OnuModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'excel_id') String? excelId,@JsonKey(name: 'numero_serial') String numeroSerial, String mac, String ssid, String password,@JsonKey(name: 'password_antigua') String? passwordAntigua,@JsonKey(name: 'cliente_nombre') String clienteNombre, String localidad, String nap, String etiqueta,@JsonKey(name: 'modelo_ont') String modeloOnt, double tx, double rx,@JsonKey(name: 'tipo_instalacion') String tipoInstalacion,@JsonKey(name: 'estado') String estado,@JsonKey(name: 'tecnico_instalador') String tecnicoInstalador,@JsonKey(name: 'soporte_provision') String soporteProvision,@JsonKey(name: 'created_by') String? createdBy,@JsonKey(name: 'updated_by') String? updatedBy
});




}
/// @nodoc
class _$OnuModelCopyWithImpl<$Res>
    implements $OnuModelCopyWith<$Res> {
  _$OnuModelCopyWithImpl(this._self, this._then);

  final OnuModel _self;
  final $Res Function(OnuModel) _then;

/// Create a copy of OnuModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? excelId = freezed,Object? numeroSerial = null,Object? mac = null,Object? ssid = null,Object? password = null,Object? passwordAntigua = freezed,Object? clienteNombre = null,Object? localidad = null,Object? nap = null,Object? etiqueta = null,Object? modeloOnt = null,Object? tx = null,Object? rx = null,Object? tipoInstalacion = null,Object? estado = null,Object? tecnicoInstalador = null,Object? soporteProvision = null,Object? createdBy = freezed,Object? updatedBy = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,excelId: freezed == excelId ? _self.excelId : excelId // ignore: cast_nullable_to_non_nullable
as String?,numeroSerial: null == numeroSerial ? _self.numeroSerial : numeroSerial // ignore: cast_nullable_to_non_nullable
as String,mac: null == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String,ssid: null == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordAntigua: freezed == passwordAntigua ? _self.passwordAntigua : passwordAntigua // ignore: cast_nullable_to_non_nullable
as String?,clienteNombre: null == clienteNombre ? _self.clienteNombre : clienteNombre // ignore: cast_nullable_to_non_nullable
as String,localidad: null == localidad ? _self.localidad : localidad // ignore: cast_nullable_to_non_nullable
as String,nap: null == nap ? _self.nap : nap // ignore: cast_nullable_to_non_nullable
as String,etiqueta: null == etiqueta ? _self.etiqueta : etiqueta // ignore: cast_nullable_to_non_nullable
as String,modeloOnt: null == modeloOnt ? _self.modeloOnt : modeloOnt // ignore: cast_nullable_to_non_nullable
as String,tx: null == tx ? _self.tx : tx // ignore: cast_nullable_to_non_nullable
as double,rx: null == rx ? _self.rx : rx // ignore: cast_nullable_to_non_nullable
as double,tipoInstalacion: null == tipoInstalacion ? _self.tipoInstalacion : tipoInstalacion // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,tecnicoInstalador: null == tecnicoInstalador ? _self.tecnicoInstalador : tecnicoInstalador // ignore: cast_nullable_to_non_nullable
as String,soporteProvision: null == soporteProvision ? _self.soporteProvision : soporteProvision // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnuModel].
extension OnuModelPatterns on OnuModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnuModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnuModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnuModel value)  $default,){
final _that = this;
switch (_that) {
case _OnuModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnuModel value)?  $default,){
final _that = this;
switch (_that) {
case _OnuModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'excel_id')  String? excelId, @JsonKey(name: 'numero_serial')  String numeroSerial,  String mac,  String ssid,  String password, @JsonKey(name: 'password_antigua')  String? passwordAntigua, @JsonKey(name: 'cliente_nombre')  String clienteNombre,  String localidad,  String nap,  String etiqueta, @JsonKey(name: 'modelo_ont')  String modeloOnt,  double tx,  double rx, @JsonKey(name: 'tipo_instalacion')  String tipoInstalacion, @JsonKey(name: 'estado')  String estado, @JsonKey(name: 'tecnico_instalador')  String tecnicoInstalador, @JsonKey(name: 'soporte_provision')  String soporteProvision, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'updated_by')  String? updatedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnuModel() when $default != null:
return $default(_that.id,_that.excelId,_that.numeroSerial,_that.mac,_that.ssid,_that.password,_that.passwordAntigua,_that.clienteNombre,_that.localidad,_that.nap,_that.etiqueta,_that.modeloOnt,_that.tx,_that.rx,_that.tipoInstalacion,_that.estado,_that.tecnicoInstalador,_that.soporteProvision,_that.createdBy,_that.updatedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'excel_id')  String? excelId, @JsonKey(name: 'numero_serial')  String numeroSerial,  String mac,  String ssid,  String password, @JsonKey(name: 'password_antigua')  String? passwordAntigua, @JsonKey(name: 'cliente_nombre')  String clienteNombre,  String localidad,  String nap,  String etiqueta, @JsonKey(name: 'modelo_ont')  String modeloOnt,  double tx,  double rx, @JsonKey(name: 'tipo_instalacion')  String tipoInstalacion, @JsonKey(name: 'estado')  String estado, @JsonKey(name: 'tecnico_instalador')  String tecnicoInstalador, @JsonKey(name: 'soporte_provision')  String soporteProvision, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'updated_by')  String? updatedBy)  $default,) {final _that = this;
switch (_that) {
case _OnuModel():
return $default(_that.id,_that.excelId,_that.numeroSerial,_that.mac,_that.ssid,_that.password,_that.passwordAntigua,_that.clienteNombre,_that.localidad,_that.nap,_that.etiqueta,_that.modeloOnt,_that.tx,_that.rx,_that.tipoInstalacion,_that.estado,_that.tecnicoInstalador,_that.soporteProvision,_that.createdBy,_that.updatedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'excel_id')  String? excelId, @JsonKey(name: 'numero_serial')  String numeroSerial,  String mac,  String ssid,  String password, @JsonKey(name: 'password_antigua')  String? passwordAntigua, @JsonKey(name: 'cliente_nombre')  String clienteNombre,  String localidad,  String nap,  String etiqueta, @JsonKey(name: 'modelo_ont')  String modeloOnt,  double tx,  double rx, @JsonKey(name: 'tipo_instalacion')  String tipoInstalacion, @JsonKey(name: 'estado')  String estado, @JsonKey(name: 'tecnico_instalador')  String tecnicoInstalador, @JsonKey(name: 'soporte_provision')  String soporteProvision, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'updated_by')  String? updatedBy)?  $default,) {final _that = this;
switch (_that) {
case _OnuModel() when $default != null:
return $default(_that.id,_that.excelId,_that.numeroSerial,_that.mac,_that.ssid,_that.password,_that.passwordAntigua,_that.clienteNombre,_that.localidad,_that.nap,_that.etiqueta,_that.modeloOnt,_that.tx,_that.rx,_that.tipoInstalacion,_that.estado,_that.tecnicoInstalador,_that.soporteProvision,_that.createdBy,_that.updatedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnuModel extends OnuModel {
  const _OnuModel({this.id, @JsonKey(name: 'excel_id') this.excelId, @JsonKey(name: 'numero_serial') required this.numeroSerial, required this.mac, required this.ssid, required this.password, @JsonKey(name: 'password_antigua') this.passwordAntigua, @JsonKey(name: 'cliente_nombre') required this.clienteNombre, required this.localidad, required this.nap, required this.etiqueta, @JsonKey(name: 'modelo_ont') required this.modeloOnt, required this.tx, required this.rx, @JsonKey(name: 'tipo_instalacion') required this.tipoInstalacion, @JsonKey(name: 'estado') this.estado = 'Libre', @JsonKey(name: 'tecnico_instalador') required this.tecnicoInstalador, @JsonKey(name: 'soporte_provision') required this.soporteProvision, @JsonKey(name: 'created_by') this.createdBy, @JsonKey(name: 'updated_by') this.updatedBy}): super._();
  factory _OnuModel.fromJson(Map<String, dynamic> json) => _$OnuModelFromJson(json);

/// ID único auto-generado por Firestore
@override final  String? id;
/// ID del Excel / CSV (identificador visible al usuario)
@override@JsonKey(name: 'excel_id') final  String? excelId;
/// Identificador de inventario único físico del aparato
@override@JsonKey(name: 'numero_serial') final  String numeroSerial;
/// Dirección física de red asignada al hardware
@override final  String mac;
/// Nombre de la red Wifi
@override final  String ssid;
/// Contraseña actual del wifi
@override final  String password;
/// Usado como respaldo para poder hacer comparativas o revertir cambios
@override@JsonKey(name: 'password_antigua') final  String? passwordAntigua;
/// Datos de identificación del cliente
@override@JsonKey(name: 'cliente_nombre') final  String clienteNombre;
@override final  String localidad;
/// Caja NAP de fibra a la que se engancha en la calle
@override final  String nap;
/// Etiqueta interna de gestión de la empresa
@override final  String etiqueta;
/// Marca y diseño del dispositivo (ej. Huawei, Nokia)
@override@JsonKey(name: 'modelo_ont') final  String modeloOnt;
/// Nivel de transmisión óptica emitido (Usualmente negativo y se mide en dBm)
@override final  double tx;
/// Nivel de recepción (señal óptica que llega a la caja)
@override final  double rx;
/// Si fue fibra nueva, migración de cobre, reubicación, etc.
@override@JsonKey(name: 'tipo_instalacion') final  String tipoInstalacion;
/// Estado en bodega del aparato (Libre, Asignado, Defectuoso)
@override@JsonKey(name: 'estado') final  String estado;
/// Nombres de los empleados involucrados en dejar este equipo funcional
@override@JsonKey(name: 'tecnico_instalador') final  String tecnicoInstalador;
@override@JsonKey(name: 'soporte_provision') final  String soporteProvision;
/// Auditoría de registros: guardan el email/nombre del responsable
@override@JsonKey(name: 'created_by') final  String? createdBy;
@override@JsonKey(name: 'updated_by') final  String? updatedBy;

/// Create a copy of OnuModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnuModelCopyWith<_OnuModel> get copyWith => __$OnuModelCopyWithImpl<_OnuModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnuModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnuModel&&(identical(other.id, id) || other.id == id)&&(identical(other.excelId, excelId) || other.excelId == excelId)&&(identical(other.numeroSerial, numeroSerial) || other.numeroSerial == numeroSerial)&&(identical(other.mac, mac) || other.mac == mac)&&(identical(other.ssid, ssid) || other.ssid == ssid)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordAntigua, passwordAntigua) || other.passwordAntigua == passwordAntigua)&&(identical(other.clienteNombre, clienteNombre) || other.clienteNombre == clienteNombre)&&(identical(other.localidad, localidad) || other.localidad == localidad)&&(identical(other.nap, nap) || other.nap == nap)&&(identical(other.etiqueta, etiqueta) || other.etiqueta == etiqueta)&&(identical(other.modeloOnt, modeloOnt) || other.modeloOnt == modeloOnt)&&(identical(other.tx, tx) || other.tx == tx)&&(identical(other.rx, rx) || other.rx == rx)&&(identical(other.tipoInstalacion, tipoInstalacion) || other.tipoInstalacion == tipoInstalacion)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.tecnicoInstalador, tecnicoInstalador) || other.tecnicoInstalador == tecnicoInstalador)&&(identical(other.soporteProvision, soporteProvision) || other.soporteProvision == soporteProvision)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,excelId,numeroSerial,mac,ssid,password,passwordAntigua,clienteNombre,localidad,nap,etiqueta,modeloOnt,tx,rx,tipoInstalacion,estado,tecnicoInstalador,soporteProvision,createdBy,updatedBy]);

@override
String toString() {
  return 'OnuModel(id: $id, excelId: $excelId, numeroSerial: $numeroSerial, mac: $mac, ssid: $ssid, password: $password, passwordAntigua: $passwordAntigua, clienteNombre: $clienteNombre, localidad: $localidad, nap: $nap, etiqueta: $etiqueta, modeloOnt: $modeloOnt, tx: $tx, rx: $rx, tipoInstalacion: $tipoInstalacion, estado: $estado, tecnicoInstalador: $tecnicoInstalador, soporteProvision: $soporteProvision, createdBy: $createdBy, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class _$OnuModelCopyWith<$Res> implements $OnuModelCopyWith<$Res> {
  factory _$OnuModelCopyWith(_OnuModel value, $Res Function(_OnuModel) _then) = __$OnuModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'excel_id') String? excelId,@JsonKey(name: 'numero_serial') String numeroSerial, String mac, String ssid, String password,@JsonKey(name: 'password_antigua') String? passwordAntigua,@JsonKey(name: 'cliente_nombre') String clienteNombre, String localidad, String nap, String etiqueta,@JsonKey(name: 'modelo_ont') String modeloOnt, double tx, double rx,@JsonKey(name: 'tipo_instalacion') String tipoInstalacion,@JsonKey(name: 'estado') String estado,@JsonKey(name: 'tecnico_instalador') String tecnicoInstalador,@JsonKey(name: 'soporte_provision') String soporteProvision,@JsonKey(name: 'created_by') String? createdBy,@JsonKey(name: 'updated_by') String? updatedBy
});




}
/// @nodoc
class __$OnuModelCopyWithImpl<$Res>
    implements _$OnuModelCopyWith<$Res> {
  __$OnuModelCopyWithImpl(this._self, this._then);

  final _OnuModel _self;
  final $Res Function(_OnuModel) _then;

/// Create a copy of OnuModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? excelId = freezed,Object? numeroSerial = null,Object? mac = null,Object? ssid = null,Object? password = null,Object? passwordAntigua = freezed,Object? clienteNombre = null,Object? localidad = null,Object? nap = null,Object? etiqueta = null,Object? modeloOnt = null,Object? tx = null,Object? rx = null,Object? tipoInstalacion = null,Object? estado = null,Object? tecnicoInstalador = null,Object? soporteProvision = null,Object? createdBy = freezed,Object? updatedBy = freezed,}) {
  return _then(_OnuModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,excelId: freezed == excelId ? _self.excelId : excelId // ignore: cast_nullable_to_non_nullable
as String?,numeroSerial: null == numeroSerial ? _self.numeroSerial : numeroSerial // ignore: cast_nullable_to_non_nullable
as String,mac: null == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String,ssid: null == ssid ? _self.ssid : ssid // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordAntigua: freezed == passwordAntigua ? _self.passwordAntigua : passwordAntigua // ignore: cast_nullable_to_non_nullable
as String?,clienteNombre: null == clienteNombre ? _self.clienteNombre : clienteNombre // ignore: cast_nullable_to_non_nullable
as String,localidad: null == localidad ? _self.localidad : localidad // ignore: cast_nullable_to_non_nullable
as String,nap: null == nap ? _self.nap : nap // ignore: cast_nullable_to_non_nullable
as String,etiqueta: null == etiqueta ? _self.etiqueta : etiqueta // ignore: cast_nullable_to_non_nullable
as String,modeloOnt: null == modeloOnt ? _self.modeloOnt : modeloOnt // ignore: cast_nullable_to_non_nullable
as String,tx: null == tx ? _self.tx : tx // ignore: cast_nullable_to_non_nullable
as double,rx: null == rx ? _self.rx : rx // ignore: cast_nullable_to_non_nullable
as double,tipoInstalacion: null == tipoInstalacion ? _self.tipoInstalacion : tipoInstalacion // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,tecnicoInstalador: null == tecnicoInstalador ? _self.tecnicoInstalador : tecnicoInstalador // ignore: cast_nullable_to_non_nullable
as String,soporteProvision: null == soporteProvision ? _self.soporteProvision : soporteProvision // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
