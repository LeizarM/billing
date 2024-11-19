// To parse this JSON data, do
//
//     final prestamoChofer = prestamoChoferFromJson(jsonString);

import 'dart:convert';

PrestamoChofer prestamoChoferFromJson(String str) => PrestamoChofer.fromJson(json.decode(str));

String prestamoChoferToJson(PrestamoChofer data) => json.encode(data.toJson());

class PrestamoChofer {
    int? idPrestamo;
    int? idCoche;
    int? idSolicitud;
    int? codSucursal;
    DateTime? fechaEntrega;
    int? codEmpEntregadoPor;
    double? kilometrajeEntrega;
    double? kilometrajeRecepcion;
    int? nivelCombustibleEntrega;
    int? nivelCombustibleRecepcion;
    int? estadoLateralesEntrega;
    int? estadoInteriorEntrega;
    int? estadoDelanteraEntrega;
    int? estadoTraseraEntrega;
    int? estadoCapoteEntrega;
    int? estadoLateralRecepcion;
    int? estadoInteriorRecepcion;
    int? estadoDelanteraRecepcion;
    int? estadoTraseraRecepcion;
    int? estadoCapoteRecepcion;
    int? audUsuario;

    PrestamoChofer({
        this.idPrestamo,
        this.idCoche,
        this.idSolicitud,
        this.codSucursal,
        this.fechaEntrega,
        this.codEmpEntregadoPor,
        this.kilometrajeEntrega,
        this.kilometrajeRecepcion,
        this.nivelCombustibleEntrega,
        this.nivelCombustibleRecepcion,
        this.estadoLateralesEntrega,
        this.estadoInteriorEntrega,
        this.estadoDelanteraEntrega,
        this.estadoTraseraEntrega,
        this.estadoCapoteEntrega,
        this.estadoLateralRecepcion,
        this.estadoInteriorRecepcion,
        this.estadoDelanteraRecepcion,
        this.estadoTraseraRecepcion,
        this.estadoCapoteRecepcion,
        this.audUsuario,
    });

    factory PrestamoChofer.fromJson(Map<String, dynamic> json) => PrestamoChofer(
        idPrestamo: json["idPrestamo"],
        idCoche: json["idCoche"],
        idSolicitud: json["idSolicitud"],
        codSucursal: json["codSucursal"],
        fechaEntrega: json["fechaEntrega"] == null ? null : DateTime.parse(json["fechaEntrega"]),
        codEmpEntregadoPor: json["codEmpEntregadoPor"],
        kilometrajeEntrega: json["kilometrajeEntrega"],
        kilometrajeRecepcion: json["kilometrajeRecepcion"],
        nivelCombustibleEntrega: json["nivelCombustibleEntrega"],
        nivelCombustibleRecepcion: json["nivelCombustibleRecepcion"],
        estadoLateralesEntrega: json["estadoLateralesEntrega"],
        estadoInteriorEntrega: json["estadoInteriorEntrega"],
        estadoDelanteraEntrega: json["estadoDelanteraEntrega"],
        estadoTraseraEntrega: json["estadoTraseraEntrega"],
        estadoCapoteEntrega: json["estadoCapoteEntrega"],
        estadoLateralRecepcion: json["estadoLateralRecepcion"],
        estadoInteriorRecepcion: json["estadoInteriorRecepcion"],
        estadoDelanteraRecepcion: json["estadoDelanteraRecepcion"],
        estadoTraseraRecepcion: json["estadoTraseraRecepcion"],
        estadoCapoteRecepcion: json["estadoCapoteRecepcion"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "idPrestamo": idPrestamo,
        "idCoche": idCoche,
        "idSolicitud": idSolicitud,
        "codSucursal": codSucursal,
        "fechaEntrega": fechaEntrega?.toIso8601String(),
        "codEmpEntregadoPor": codEmpEntregadoPor,
        "kilometrajeEntrega": kilometrajeEntrega,
        "kilometrajeRecepcion": kilometrajeRecepcion,
        "nivelCombustibleEntrega": nivelCombustibleEntrega,
        "nivelCombustibleRecepcion": nivelCombustibleRecepcion,
        "estadoLateralesEntrega": estadoLateralesEntrega,
        "estadoInteriorEntrega": estadoInteriorEntrega,
        "estadoDelanteraEntrega": estadoDelanteraEntrega,
        "estadoTraseraEntrega": estadoTraseraEntrega,
        "estadoCapoteEntrega": estadoCapoteEntrega,
        "estadoLateralRecepcion": estadoLateralRecepcion,
        "estadoInteriorRecepcion": estadoInteriorRecepcion,
        "estadoDelanteraRecepcion": estadoDelanteraRecepcion,
        "estadoTraseraRecepcion": estadoTraseraRecepcion,
        "estadoCapoteRecepcion": estadoCapoteRecepcion,
        "audUsuario": audUsuario,
    };
}
