import 'package:billing/domain/delivery-driver/deliverDriver.dart';

abstract class DeliveryDriverRepository {
  Future<List<DeliveryDriver>> obtainDelivery(int codEmpleado);
}
