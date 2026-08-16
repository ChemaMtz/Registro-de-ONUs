// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onu_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnuModel _$OnuModelFromJson(Map<String, dynamic> json) => _OnuModel(
  id: json['id'] as String?,
  excelId: json['excel_id'] as String?,
  numeroSerial: json['numero_serial'] as String,
  mac: json['mac'] as String,
  ssid: json['ssid'] as String,
  password: json['password'] as String,
  passwordAntigua: json['password_antigua'] as String?,
  clienteNombre: json['cliente_nombre'] as String,
  localidad: json['localidad'] as String,
  nap: json['nap'] as String,
  etiqueta: json['etiqueta'] as String,
  modeloOnt: json['modelo_ont'] as String,
  tx: (json['tx'] as num).toDouble(),
  rx: (json['rx'] as num).toDouble(),
  tipoInstalacion: json['tipo_instalacion'] as String,
  estado: json['estado'] as String? ?? 'Libre',
  tecnicoInstalador: json['tecnico_instalador'] as String,
  soporteProvision: json['soporte_provision'] as String,
  createdBy: json['created_by'] as String?,
  updatedBy: json['updated_by'] as String?,
);

Map<String, dynamic> _$OnuModelToJson(_OnuModel instance) => <String, dynamic>{
  'id': instance.id,
  'excel_id': instance.excelId,
  'numero_serial': instance.numeroSerial,
  'mac': instance.mac,
  'ssid': instance.ssid,
  'password': instance.password,
  'password_antigua': instance.passwordAntigua,
  'cliente_nombre': instance.clienteNombre,
  'localidad': instance.localidad,
  'nap': instance.nap,
  'etiqueta': instance.etiqueta,
  'modelo_ont': instance.modeloOnt,
  'tx': instance.tx,
  'rx': instance.rx,
  'tipo_instalacion': instance.tipoInstalacion,
  'estado': instance.estado,
  'tecnico_instalador': instance.tecnicoInstalador,
  'soporte_provision': instance.soporteProvision,
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
};
