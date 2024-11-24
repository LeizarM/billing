// To parse this JSON data, do
//
//     final prestamoEstado = prestamoEstadoFromJson(jsonString);

import 'dart:convert';

PrestamoEstado prestamoEstadoFromJson(String str) => PrestamoEstado.fromJson(json.decode(str));

String prestamoEstadoToJson(PrestamoEstado data) => json.encode(data.toJson());

class PrestamoEstado {
    int? idPe;
    int? idPrestamo;
    int? idEst;
    String? momento;
    int? audUsuario;

    PrestamoEstado({
        this.idPe,
        this.idPrestamo,
        this.idEst,
        this.momento,
        this.audUsuario,
    });

    factory PrestamoEstado.fromJson(Map<String, dynamic> json) => PrestamoEstado(
        idPe: json["idPE"],
        idPrestamo: json["idPrestamo"],
        idEst: json["idEst"],
        momento: json["momento"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "idPE": idPe,
        "idPrestamo": idPrestamo,
        "idEst": idEst,
        "momento": momento,
        "audUsuario": audUsuario,
    };
}
