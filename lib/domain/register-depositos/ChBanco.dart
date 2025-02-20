// To parse this JSON data, do
//
//     final chBanco = chBancoFromJson(jsonString);

import 'dart:convert';

ChBanco chBancoFromJson(String str) => ChBanco.fromJson(json.decode(str));

String chBancoToJson(ChBanco data) => json.encode(data.toJson());

class ChBanco {
    int? codBanco;
    String? nombre;
    int? audUsuario;
    int? fila;

    ChBanco({
        this.codBanco,
        this.nombre,
        this.audUsuario,
        this.fila,
    });

    factory ChBanco.fromJson(Map<String, dynamic> json) => ChBanco(
        codBanco: json["codBanco"],
        nombre: json["nombre"],
        audUsuario: json["audUsuario"],
        fila: json["fila"],
    );

    Map<String, dynamic> toJson() => {
        "codBanco": codBanco,
        "nombre": nombre,
        "audUsuario": audUsuario,
        "fila": fila,
    };
}
