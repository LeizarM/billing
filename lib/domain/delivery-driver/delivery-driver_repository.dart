import 'package:billing/domain/delivery-driver/deliverDriver.dart';

abstract class DeliveryDriverRepository {
  
  
  Future<List<DeliveryDriver>> obtainDelivery(int codEmpleado);

  Future<void> saveDeliveryData(
      {required int docEntry,
      required String db,
      required double latitude,
      required double longitude,
      required String address,
      required String dateTime,
      required String obs,
      required int audUsuario});

  Future<void> registerStartDelivery(DeliveryDriver mb);

  Future<void> registerFinishDelivery(DeliveryDriver mb);

  Future<void> obtainDriver();

  Future<List<DeliveryDriver>> obtainDeliveriesXEmp(int codEmpleado, String fecha);

}
