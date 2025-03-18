// To parse this JSON data, do
//
//     final bancoXCuenta = bancoXCuentaFromJson(jsonString);

import 'dart:convert';

BancoXCuenta bancoXCuentaFromJson(String str) => BancoXCuenta.fromJson(json.decode(str));

String bancoXCuentaToJson(BancoXCuenta data) => json.encode(data.toJson());

class BancoXCuenta {
    int? idBxC;
    int? codBanco;
    String? numCuenta;
    String? moneda;
    int? codEmpresa;
    int? audUsuario;
    String? nombreBanco;

    BancoXCuenta({
        this.idBxC,
        this.codBanco,
        this.numCuenta,
        this.moneda,
        this.codEmpresa,
        this.audUsuario,
        this.nombreBanco,
    });

    factory BancoXCuenta.fromJson(Map<String, dynamic> json) => BancoXCuenta(
        idBxC: json["idBxC"],
        codBanco: json["codBanco"],
        numCuenta: json["numCuenta"],
        moneda: json["moneda"],
        codEmpresa: json["codEmpresa"],
        audUsuario: json["audUsuario"],
        nombreBanco: json["nombreBanco"],
    );

    Map<String, dynamic> toJson() => {
        "idBxC": idBxC,
        "codBanco": codBanco,
        "numCuenta": numCuenta,
        "moneda": moneda,
        "codEmpresa": codEmpresa,
        "audUsuario": audUsuario,
        "nombreBanco": nombreBanco,
    };
}
