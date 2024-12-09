import 'dart:convert';

TipoSolicitud tipoSolicitudFromJson(String str) => TipoSolicitud.fromJson(json.decode(str));

String tipoSolicitudToJson(TipoSolicitud data) => json.encode(data.toJson());

class TipoSolicitud {
    int? idEs;
    String? descripcion;
    int? estado;
    int? audUsuario;

    TipoSolicitud({
        this.idEs,
        this.descripcion,
        this.estado,
        this.audUsuario,
    });

    factory TipoSolicitud.fromJson(Map<String, dynamic> json) => TipoSolicitud(
        idEs: json["idES"],
        descripcion: json["descripcion"],
        estado: json["estado"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "idES": idEs,
        "descripcion": descripcion,
        "estado": estado,
        "audUsuario": audUsuario,
    };
}