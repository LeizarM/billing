

import 'package:billing/domain/driver-car/PrestamoChofer.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';

abstract class SolicitudChoferRepository {

  
  Future<void> registerSolicitudChofer(SolicitudChofer mb);

  
  Future<void> obtainSolicitudes(   int codEmpleado );


  Future<void> lstEstados();
  
  
  Future<void> registerPrestamo(PrestamoChofer mb);


  Future<void> obtainCoches();

}