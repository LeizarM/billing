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
    };
}
