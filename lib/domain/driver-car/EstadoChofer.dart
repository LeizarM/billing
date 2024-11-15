import 'dart:convert';

EstadoChofer estadoChoferFromJson(String str) => EstadoChofer.fromJson(json.decode(str));

String estadoChoferToJson(EstadoChofer data) => json.encode(data.toJson());

class EstadoChofer {
    int? idEst;
    String? estado;
    int? audUsuario;

    EstadoChofer({
        this.idEst,
        this.estado,
        this.audUsuario,
    });

    factory EstadoChofer.fromJson(Map<String, dynamic> json) => EstadoChofer(
        idEst: json["idEst"],
        estado: json["estado"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "idEst": idEst,
        "estado": estado,
        "audUsuario": audUsuario,
    };
}
