// To parse this JSON data, do
//
//     final socioNegocio = socioNegocioFromJson(jsonString);

import 'dart:convert';

SocioNegocio socioNegocioFromJson(String str) => SocioNegocio.fromJson(json.decode(str));

String socioNegocioToJson(SocioNegocio data) => json.encode(data.toJson());

class SocioNegocio {
    String? codCliente;
    String? datoCliente;
    String? razonSocial;
    String? nit;
    int? codCiudad;
    String? datoCiudad;
    String? esVigente;
    int? codEmpresa;
    int? audUsuario;
    String? nombreCompleto;

    SocioNegocio({
        this.codCliente,
        this.datoCliente,
        this.razonSocial,
        this.nit,
        this.codCiudad,
        this.datoCiudad,
        this.esVigente,
        this.codEmpresa,
        this.audUsuario,
        this.nombreCompleto,
    });

    factory SocioNegocio.fromJson(Map<String, dynamic> json) => SocioNegocio(
        codCliente: json["codCliente"],
        datoCliente: json["datoCliente"],
        razonSocial: json["razonSocial"],
        nit: json["nit"],
        codCiudad: json["codCiudad"],
        datoCiudad: json["datoCiudad"],
        esVigente: json["esVigente"],
        codEmpresa: json["codEmpresa"],
        audUsuario: json["audUsuario"],
        nombreCompleto: json["nombreCompleto"],
    );

    Map<String, dynamic> toJson() => {
        "codCliente": codCliente,
        "datoCliente": datoCliente,
        "razonSocial": razonSocial,
        "nit": nit,
        "codCiudad": codCiudad,
        "datoCiudad": datoCiudad,
        "esVigente": esVigente,
        "codEmpresa": codEmpresa,
        "audUsuario": audUsuario,
        "nombreCompleto": nombreCompleto,
    };
}
