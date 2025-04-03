
// To parse this JSON data, do
//
//     final combustibleControl = combustibleControlFromJson(jsonString);

import 'dart:convert';

CombustibleControl combustibleControlFromJson(String str) => CombustibleControl.fromJson(json.decode(str));

String combustibleControlToJson(CombustibleControl data) => json.encode(data.toJson());

class CombustibleControl {
    int? idC;
    DateTime? fecha;
    String? estacionServicio;
    String? nroFactura;
    double? importe;
    double? kilometraje;
    int? codEmpleado;
    double? diferencia;
    int? codSucursalCoche;
    String? obs;
    int? audUsuario;
    int? idCoche;
    String? coche;

    CombustibleControl({
        this.idC,
        this.fecha,
        this.estacionServicio,
        this.nroFactura,
        this.importe,
        this.kilometraje,
        this.codEmpleado,
        this.diferencia,
        this.codSucursalCoche,
        this.obs,
        this.audUsuario,
        this.idCoche,
        this.coche,
    });

    factory CombustibleControl.fromJson(Map<String, dynamic> json) => CombustibleControl(
        idC: json["idC"],
        fecha: json["fecha"] == null ? null : DateTime.parse(json["fecha"]),
        estacionServicio: json["estacionServicio"],
        nroFactura: json["nroFactura"],
        importe: json["importe"],
        kilometraje: json["kilometraje"],
        codEmpleado: json["codEmpleado"],
        diferencia: json["diferencia"],
        codSucursalCoche: json["codSucursalCoche"],
        obs: json["obs"],
        audUsuario: json["audUsuario"],
        idCoche: json["idCoche"],
        coche: json["coche"],
    );

    Map<String, dynamic> toJson() => {
        "idC": idC,
        "fecha": fecha?.toIso8601String(),
        "estacionServicio": estacionServicio,
        "nroFactura": nroFactura,
        "importe": importe,
        "kilometraje": kilometraje,
        "codEmpleado": codEmpleado,
        "diferencia": diferencia,
        "codSucursalCoche": codSucursalCoche,
        "obs": obs,
        "audUsuario": audUsuario,
        "idCoche": idCoche,
        "coche": coche,
    };
}
