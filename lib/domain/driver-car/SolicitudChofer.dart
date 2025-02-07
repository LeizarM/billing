import 'dart:convert';

SolicitudChofer solicitudChoferFromJson(String str) => SolicitudChofer.fromJson(json.decode(str));

String solicitudChoferToJson(SolicitudChofer data) => json.encode(data.toJson());

class SolicitudChofer {
    int? idSolicitud;
    DateTime? fechaSolicitud;
    String? motivo;
    int? codEmpSoli;
    String? cargo;
    int? estado;
    int? audUsuario;
    String? fechaSolicitudCad;
    String? estadoCad;
    int? idCocheSol;
    int? idES;
    int? requiereChofer;
    int? codSucursal;
    String? coche;
   
    SolicitudChofer({
        this.idSolicitud,
        this.fechaSolicitud,
        this.motivo,
        this.codEmpSoli,
        this.cargo,
        this.estado,
        this.audUsuario,
        this.fechaSolicitudCad,
        this.estadoCad,
        this.idCocheSol,
        this.idES,
        this.requiereChofer,
        this.codSucursal,
        this.coche,
    });

    factory SolicitudChofer.fromJson(Map<String, dynamic> json) => SolicitudChofer(
        idSolicitud: json["idSolicitud"],
        fechaSolicitud: json["fechaSolicitud"] == null ? null : DateTime.parse(json["fechaSolicitud"]),
        motivo: json["motivo"],
        codEmpSoli: json["codEmpSoli"],
        cargo: json["cargo"],
        estado: json["estado"],
        audUsuario: json["audUsuario"],
        fechaSolicitudCad: json["fechaSolicitudCad"],
        estadoCad: json["estadoCad"],
        idCocheSol: json["idCocheSol"],
        idES: json["idES"],
        requiereChofer: json["requiereChofer"],
        codSucursal: json["codSucursal"],
        coche: json["coche"],
    );

    Map<String, dynamic> toJson() => {
        "idSolicitud": idSolicitud,
        "fechaSolicitud": fechaSolicitud?.toIso8601String(),
        "motivo": motivo,
        "codEmpSoli": codEmpSoli,
        "cargo": cargo,
        "estado": estado,
        "audUsuario": audUsuario,
        "fechaSolicitudCad": fechaSolicitudCad,
        "estadoCad": estadoCad,
        "idCocheSol": idCocheSol,
        "idES": idES,
        "requiereChofer": requiereChofer,
        "codSucursal": codSucursal,
        "coche": coche,
    };
}
