import 'package:billing/domain/delivery-driver/deliverDriver.dart';

class GroupedDelivery {
  final int docEntry;
  final String cardName;
  final DateTime docDate;
  final String addressEntregaMat;
  final List<DeliveryDriver> items;
  final String db; // Agregamos el campo db
  bool isDelivered;

  GroupedDelivery({
    required this.docEntry,
    required this.cardName,
    required this.docDate,
    required this.addressEntregaMat,
    required this.items,
    required this.db, // Añadimos db como parámetro requerido
    this.isDelivered = false,
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity!);
}
