

import 'package:billing/domain/driver-car/SolicitudChofer.dart';

abstract class SolicitudChoferRepository {

  

  Future<void> registerSolicitudChofer(SolicitudChofer mb);

  
  Future<void> obtainSolicitudes(   int codEmpleado );

  
}