import 'dart:convert';

DepositoCheque depositoChequeFromJson(String str) => DepositoCheque.fromJson(json.decode(str));

String depositoChequeToJson(DepositoCheque data) => json.encode(data.toJson());

class DepositoCheque {
    int? idDeposito;
    String? codCliente;
    int? docNum;
    int? numFact;
    int? anioFact;
    int? codEmpresa;
    int? codBanco;
    int? importe;
    String? moneda;
    int? estado;
    String? fotoPath;
    int? audUsuario;
    String? nombreBanco;
    String? nombreEmpresa;

    DepositoCheque({
        this.idDeposito,
        this.codCliente,
        this.docNum,
        this.numFact,
        this.anioFact,
        this.codEmpresa,
        this.codBanco,
        this.importe,
        this.moneda,
        this.estado,
        this.fotoPath,
        this.audUsuario,
        this.nombreBanco,
        this.nombreEmpresa,
    });

    factory DepositoCheque.fromJson(Map<String, dynamic> json) => DepositoCheque(
        idDeposito: json["idDeposito"],
        codCliente: json["codCliente"],
        docNum: json["docNum"],
        numFact: json["numFact"],
        anioFact: json["anioFact"],
        codEmpresa: json["codEmpresa"],
        codBanco: json["codBanco"],
        importe: json["importe"],
        moneda: json["moneda"],
        estado: json["estado"],
        fotoPath: json["fotoPath"],
        audUsuario: json["audUsuario"],
        nombreBanco: json["nombreBanco"],
        nombreEmpresa: json["nombreEmpresa"],
    );

    Map<String, dynamic> toJson() => {
        "idDeposito": idDeposito,
        "codCliente": codCliente,
        "docNum": docNum,
        "numFact": numFact,
        "anioFact": anioFact,
        "codEmpresa": codEmpresa,
        "codBanco": codBanco,
        "importe": importe,
        "moneda": moneda,
        "estado": estado,
        "fotoPath": fotoPath,
        "audUsuario": audUsuario,
        "nombreBanco": nombreBanco,
        "nombreEmpresa": nombreEmpresa,
    };
}
