// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

// Archivos auto-generados por el paquete 'freezed' y 'json_serializable'
part 'onu_model.freezed.dart';
part 'onu_model.g.dart';

/// [OnuModel] es la estructura de datos que representa una ONT (Modem Óptico)
/// en toda la aplicación.
/// Usa la librería Freezed para ser inmutable y obligar al tipado seguro.
@freezed
abstract class OnuModel with _$OnuModel {
  const OnuModel._();

  const factory OnuModel({
    /// ID único auto-generado por Firestore
    String? id,

    /// ID del Excel / CSV (identificador visible al usuario)
    @JsonKey(name: 'excel_id') String? excelId,

    /// Identificador de inventario único físico del aparato
    @JsonKey(name: 'numero_serial') required String numeroSerial,

    /// Dirección física de red asignada al hardware
    required String mac,

    /// Nombre de la red Wifi
    required String ssid,

    /// Contraseña actual del wifi
    required String password,

    /// Usado como respaldo para poder hacer comparativas o revertir cambios
    @JsonKey(name: 'password_antigua') String? passwordAntigua,

    /// Datos de identificación del cliente
    @JsonKey(name: 'cliente_nombre') required String clienteNombre,
    required String localidad,

    /// Caja NAP de fibra a la que se engancha en la calle
    required String nap,

    /// Etiqueta interna de gestión de la empresa
    required String etiqueta,

    /// Marca y diseño del dispositivo (ej. Huawei, Nokia)
    @JsonKey(name: 'modelo_ont') required String modeloOnt,

    /// Nivel de transmisión óptica emitido (Usualmente negativo y se mide en dBm)
    required double tx,

    /// Nivel de recepción (señal óptica que llega a la caja)
    required double rx,

    /// Si fue fibra nueva, migración de cobre, reubicación, etc.
    @JsonKey(name: 'tipo_instalacion') required String tipoInstalacion,

    /// Estado en bodega del aparato (Libre, Asignado, Defectuoso)
    @JsonKey(name: 'estado') @Default('Libre') String estado,

    /// Nombres de los empleados involucrados en dejar este equipo funcional
    @JsonKey(name: 'tecnico_instalador') required String tecnicoInstalador,
    @JsonKey(name: 'soporte_provision') required String soporteProvision,

    /// Auditoría de registros: guardan el email/nombre del responsable
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
  }) = _OnuModel;

  /// Constructor de fábrica que convierte un Diccionario JSON devuelto por
  /// la base de datos en una instancia manejable de [OnuModel].
  factory OnuModel.fromJson(Map<String, dynamic> json) =>
      _$OnuModelFromJson(json);
}
