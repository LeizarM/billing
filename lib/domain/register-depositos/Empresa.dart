// To parse this JSON data, do
//
//     final empresa = empresaFromJson(jsonString);

import 'dart:convert';

Empresa empresaFromJson(String str) => Empresa.fromJson(json.decode(str));

String empresaToJson(Empresa data) => json.encode(data.toJson());

class Empresa {
    int? codEmpresa;
    String? nombre;
    int? codPadre;
    String? sigla;
    int? audUsuario;

    Empresa({
        this.codEmpresa,
        this.nombre,
        this.codPadre,
        this.sigla,
        this.audUsuario,
    });

    factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
        codEmpresa: json["codEmpresa"],
        nombre: json["nombre"],
        codPadre: json["codPadre"],
        sigla: json["sigla"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "codEmpresa": codEmpresa,
        "nombre": nombre,
        "codPadre": codPadre,
        "sigla": sigla,
        "audUsuario": audUsuario,
    };
}
