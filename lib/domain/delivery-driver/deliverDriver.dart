import 'dart:convert';

DeliveryDriver deliveryDriverFromJson(String str) =>
    DeliveryDriver.fromJson(json.decode(str));

String deliveryDriverToJson(DeliveryDriver data) => json.encode(data.toJson());

class DeliveryDriver {
  int? idEntrega;
  int? docEntry;
  int? docNum;
  int? docNumF;
  int? factura;
  DateTime? docDate;
  String? docTime;
  String? cardCode;
  String? cardName;
  String? addressEntregaFac;
  String? addressEntregaMat;
  String? vendedor;
  int? uChofer;
  String? itemCode;
  String? dscription;
  String? whsCode;
  int? quantity;
  int? openQty;
  String? db;
  String? valido;
  double? peso;
  String? cochePlaca;
  String? prioridad;
  String? tipo;
  String? obsF;
  int? fueEntregado;
  String? fechaEntrega;
  num? latitud;
  num? longitud;
  String? direccionEntrega;
  String? obs;
  num? codSucursalChofer;
  num? codCiudadChofer;
  int? audUsuario;


  String? fechaNota;
  String? nombreCompleto;
  int?  diferenciaMinutos;
  int? codEmpleado;
  String? cargo;

  DeliveryDriver(
      {this.idEntrega,
      this.docEntry,
      this.docNum,
      this.docNumF,
      this.factura,
      this.docDate,
      this.docTime,
      this.cardCode,
      this.cardName,
      this.addressEntregaFac,
      this.addressEntregaMat,
      this.vendedor,
      this.uChofer,
      this.itemCode,
      this.dscription,
      this.whsCode,
      this.quantity,
      this.openQty,
      this.db,
      this.valido,
      this.peso,
      this.cochePlaca,
      this.prioridad,
      this.tipo,
      this.obsF,
      this.fueEntregado,
      this.fechaEntrega,
      this.latitud,
      this.longitud,
      this.direccionEntrega,
      this.obs,
      this.codSucursalChofer,
      this.codCiudadChofer,
      this.audUsuario,
      this.fechaNota,
      this.nombreCompleto,
      this.diferenciaMinutos,
      this.codEmpleado,
      this.cargo});

  factory DeliveryDriver.fromJson(Map<String, dynamic> json) => DeliveryDriver(
        idEntrega: json["idEntrega"],
        docEntry: json["docEntry"],
        docNum: json["docNum"],
        docNumF: json["docNumF"],
        factura: json["factura"],
        docDate: json["docDate"] != null ? DateTime.parse(json["docDate"]) : null,
        docTime: json["docTime"],
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        addressEntregaFac: json["addressEntregaFac"],
        addressEntregaMat: json["addressEntregaMat"],
        vendedor: json["vendedor"],
        uChofer: json["uChofer"],
        itemCode: json["itemCode"],
        dscription: json["dscription"],
        whsCode: json["whsCode"],
        quantity: json["quantity"],
        openQty: json["openQty"],
        db: json["db"],
        valido: json["valido"],
        peso: json["peso"],
        cochePlaca: json["cochePlaca"],
        prioridad: json["prioridad"],
        tipo: json["tipo"],
        obsF: json["obsF"],
        fueEntregado: json["fueEntregado"],
        fechaEntrega: json["fechaEntrega"],
        latitud: json["latitud"],
        longitud: json["longitud"],
        direccionEntrega: json["direccionEntrega"],
        obs: json["obs"],
        codSucursalChofer: json["codSucursalChofer"],
        codCiudadChofer: json["codCiudadChofer"],
        audUsuario: json["audUsuario"],
        fechaNota: json["fechaNota"],
        nombreCompleto: json["nombreCompleto"],
        diferenciaMinutos: json["diferenciaMinutos"],
        codEmpleado: json["codEmpleado"],
        cargo: json["cargo"],

      );

  Map<String, dynamic> toJson() => {
        "idEntrega": idEntrega,
        "docEntry": docEntry,
        "docNum": docNum,
        "docNumF": docNumF,
        "factura": factura,
        "docDate": docDate,
        "docTime": docTime,
        "cardCode": cardCode,
        "cardName": cardName,
        "addressEntregaFac": addressEntregaFac,
        "addressEntregaMat": addressEntregaMat,
        "vendedor": vendedor,
        "uChofer": uChofer,
        "itemCode": itemCode,
        "dscription": dscription,
        "whsCode": whsCode,
        "quantity": quantity,
        "openQty": openQty,
        "db": db,
        "valido": valido,
        "peso": peso,
        "cochePlaca": cochePlaca,
        "prioridad": prioridad,
        "tipo": tipo,
        "obsF": obsF,
        "fueEntregado": fueEntregado,
        "fechaEntrega": fechaEntrega,
        "latitud": latitud,
        "longitud": longitud,
        "direccionEntrega": direccionEntrega,
        "obs": obs,
        "codSucursalChofer": codSucursalChofer,
        "codCiudadChofer": codCiudadChofer,
        "audUsuario": audUsuario,
        "fechaNota": fechaNota,
        "nombreCompleto": nombreCompleto,
        "diferenciaMinutos": diferenciaMinutos,
        "codEmpleado": codEmpleado,
        "cargo": cargo,
      };
}