// To parse this JSON data, do
//
//     final notaRemision = notaRemisionFromJson(jsonString);

import 'dart:convert';

NotaRemision notaRemisionFromJson(String str) => NotaRemision.fromJson(json.decode(str));

String notaRemisionToJson(NotaRemision data) => json.encode(data.toJson());

class NotaRemision {
    int? idNr;
    int? idDeposito;
    int? docNum;
    DateTime? fecha;
    int? numFact;
    double? totalMonto;
    double? saldoPendiente;
    int? audUsuario;
    String? codCliente;
    String? nombreCliente;
    String? db;
    int? codEmpresaBosque;

    NotaRemision({
        this.idNr,
        this.idDeposito,
        this.docNum,
        this.fecha,
        this.numFact,
        this.totalMonto,
        this.saldoPendiente,
        this.audUsuario,
        this.codCliente,
        this.nombreCliente,
        this.db,
        this.codEmpresaBosque,
    });

    factory NotaRemision.fromJson(Map<String, dynamic> json) => NotaRemision(
        idNr: json["idNR"],
        idDeposito: json["idDeposito"],
        docNum: json["docNum"],
        fecha: json["fecha"] == null ? null : DateTime.parse(json["fecha"]),
        numFact: json["numFact"],
        totalMonto: json["totalMonto"],
        saldoPendiente: json["saldoPendiente"],
        audUsuario: json["audUsuario"],
        codCliente: json["codCliente"],
        nombreCliente: json["nombreCliente"],
        db: json["db"],
        codEmpresaBosque: json["codEmpresaBosque"],
    );

    Map<String, dynamic> toJson() => {
        "idNR": idNr,
        "idDeposito": idDeposito,
        "docNum": docNum,
        "fecha": fecha?.toIso8601String(),
        "numFact": numFact,
        "totalMonto": totalMonto,
        "saldoPendiente": saldoPendiente,
        "audUsuario": audUsuario,
        "codCliente": codCliente,
        "nombreCliente": nombreCliente,
        "db": db,
        "codEmpresaBosque": codEmpresaBosque,
    };
}
