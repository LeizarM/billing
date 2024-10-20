import 'dart:convert';

DeliveryDriver deliveryDriverFromJson(String str) =>
    DeliveryDriver.fromJson(json.decode(str));

String deliveryDriverToJson(DeliveryDriver data) => json.encode(data.toJson());

class DeliveryDriver {
  int? idEntrega;
  int? docEntry;
  int? docNum;
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
  int? fueEntregado;
  String? fechaEntrega;
  num? latitud;
  num? longitud;
  String? direccionEntrega;
  String? obs;
  int? audUsuario;
  int? codEmpleado;

  DeliveryDriver(
      {this.idEntrega,
      this.docEntry,
      this.docNum,
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
      this.fueEntregado,
      this.fechaEntrega,
      this.latitud,
      this.longitud,
      this.direccionEntrega,
      this.obs,
      this.audUsuario,
      this.codEmpleado});

  factory DeliveryDriver.fromJson(Map<String, dynamic> json) => DeliveryDriver(
        idEntrega: json["idEntrega"],
        docEntry: json["docEntry"],
        docNum: json["docNum"],
        factura: json["factura"],
        docDate: DateTime.parse(json["docDate"]),
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
        fueEntregado: json["fueEntregado"],
        fechaEntrega: json["fechaEntrega"],
        latitud: json["latitud"],
        longitud: json["longitud"],
        direccionEntrega: json["direccionEntrega"],
        obs: json["obs"],
        audUsuario: json["audUsuario"],
        codEmpleado: json["codEmpleado"],
      );

  Map<String, dynamic> toJson() => {
        "idEntrega": idEntrega,
        "docEntry": docEntry,
        "docNum": docNum,
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
        "fueEntregado": fueEntregado,
        "fechaEntrega": fechaEntrega,
        "latitud": latitud,
        "longitud": longitud,
        "direccionEntrega": direccionEntrega,
        "obs": obs,
        "audUsuario": audUsuario,
        "codEmpleado": codEmpleado,
      };
}
