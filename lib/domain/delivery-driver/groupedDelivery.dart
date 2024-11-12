import 'package:billing/domain/delivery-driver/deliverDriver.dart';

class GroupedDelivery {
  int docEntry;
  String cardName;
  DateTime docDate;
  String addressEntregaMat;
  List<DeliveryDriver> items;
  String obs;
  String db; // Agregamos el campo db
  bool isDelivered;
  String? tipo; // Agregamos el campo tipo
  String? obsF;

  GroupedDelivery({
    required this.docEntry,
    required this.cardName,
    required this.docDate,
    required this.addressEntregaMat,
    required this.items,
    required this.obs,
    required this.db, // Añadimos db como parámetro requerido
    this.isDelivered = false,
    this.tipo,
    this.obsF,
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity!);
}
