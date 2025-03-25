// To parse this JSON data, do
//
//     final depositoCheque = depositoChequeFromJson(jsonString);

import 'dart:convert';

DepositoCheque depositoChequeFromJson(String str) => DepositoCheque.fromJson(json.decode(str));

String depositoChequeToJson(DepositoCheque data) => json.encode(data.toJson());

class DepositoCheque {
    int? idDeposito;
    String? codCliente;
    int? codEmpresa;
    int? idBxC;
    double? importe;
    String? moneda;
    int? estado;
    String? fotoPath;
    double? aCuenta;
    DateTime? fechaI;
    String? nroTransaccion;
    String? obs;
    int? audUsuario;
    int? codBanco;
    DateTime? fechaInicio;
    DateTime? fechaFin;
    String? nombreBanco;
    String? nombreEmpresa;
    String? esPendiente;
    String? numeroDeDocumentos;
    String? fechasDeDepositos;
    String? numeroDeFacturas;
    String? totalMontos;
    String? estadoFiltro;

    DepositoCheque({
        this.idDeposito,
        this.codCliente,
        this.codEmpresa,
        this.idBxC,
        this.importe,
        this.moneda,
        this.estado,
        this.fotoPath,
        this.aCuenta,
        this.fechaI,
        this.nroTransaccion,
        this.obs,
        this.audUsuario,
        this.codBanco,
        this.fechaInicio,
        this.fechaFin,
        this.nombreBanco,
        this.nombreEmpresa,
        this.esPendiente,
        this.numeroDeDocumentos,
        this.fechasDeDepositos,
        this.numeroDeFacturas,
        this.totalMontos,
        this.estadoFiltro,
    });

    factory DepositoCheque.fromJson(Map<String, dynamic> json) => DepositoCheque(
        idDeposito: json["idDeposito"],
        codCliente: json["codCliente"],
        codEmpresa: json["codEmpresa"],
        idBxC: json["idBxC"],
        importe: json["importe"],
        moneda: json["moneda"],
        estado: json["estado"],
        fotoPath: json["fotoPath"],
        aCuenta: json["aCuenta"],
        fechaI: json["fechaI"] == null ? null : DateTime.parse(json["fechaI"]),
        nroTransaccion: json["nroTransaccion"],
        obs: json["obs"],
        audUsuario: json["audUsuario"],
        codBanco: json["codBanco"],
        fechaInicio: json["fechaInicio"] == null ? null : DateTime.parse(json["fechaInicio"]),
        fechaFin: json["fechaFin"] == null ? null : DateTime.parse(json["fechaFin"]),
        nombreBanco: json["nombreBanco"],
        nombreEmpresa: json["nombreEmpresa"],
        esPendiente: json["esPendiente"],
        numeroDeDocumentos: json["numeroDeDocumentos"],
        fechasDeDepositos: json["fechasDeDepositos"],
        numeroDeFacturas: json["numeroDeFacturas"],
        totalMontos: json["totalMontos"],
        estadoFiltro: json["estadoFiltro"],
    );

    Map<String, dynamic> toJson() => {
        "idDeposito": idDeposito,
        "codCliente": codCliente,
        "codEmpresa": codEmpresa,
        "idBxC": idBxC,
        "importe": importe,
        "moneda": moneda,
        "estado": estado,
        "fotoPath": fotoPath,
        "aCuenta": aCuenta,
        "fechaI": fechaI?.toIso8601String(),
        "nroTransaccion": nroTransaccion,
        "obs": obs,
        "audUsuario": audUsuario,
        "codBanco": codBanco,
        "fechaInicio": fechaInicio?.toIso8601String(),
        "fechaFin": fechaFin?.toIso8601String(),
        "nombreBanco": nombreBanco,
        "nombreEmpresa": nombreEmpresa,
        "esPendiente": esPendiente,
        "numeroDeDocumentos": numeroDeDocumentos,
        "fechasDeDepositos": fechasDeDepositos,
        "numeroDeFacturas": numeroDeFacturas,
        "totalMontos": totalMontos,
        "estadoFiltro": estadoFiltro,
    };
}
