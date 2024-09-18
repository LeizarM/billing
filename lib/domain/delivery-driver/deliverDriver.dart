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
  DateTime? fechaEntrega;
  num? latitud;
  num? longitud;
  String? direccionEntrega;
  String? obs;
  int? audUsuario;

  DeliveryDriver({
    required this.idEntrega,
    required this.docEntry,
    required this.docNum,
    required this.factura,
    required this.docDate,
    required this.docTime,
    required this.cardCode,
    required this.cardName,
    required this.addressEntregaFac,
    required this.addressEntregaMat,
    required this.vendedor,
    required this.uChofer,
    required this.itemCode,
    required this.dscription,
    required this.whsCode,
    required this.quantity,
    required this.openQty,
    required this.db,
    required this.valido,
    required this.fueEntregado,
    required this.fechaEntrega,
    required this.latitud,
    required this.longitud,
    required this.direccionEntrega,
    required this.obs,
    required this.audUsuario,
  });

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
        fechaEntrega: DateTime.parse(json["fechaEntrega"]),
        latitud: json["latitud"],
        longitud: json["longitud"],
        direccionEntrega: json["direccionEntrega"],
        obs: json["obs"],
        audUsuario: json["audUsuario"],
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
      };
}
