

import 'package:billing/domain/driver-car/PrestamoChofer.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';
import 'package:billing/domain/driver-car/TipoSolicitud.dart';

abstract class SolicitudChoferRepository {

  
  Future<void> registerSolicitudChofer(SolicitudChofer mb);

  
  Future<void> obtainSolicitudes(   int codEmpleado );


  Future<void> lstEstados();
  
  
  Future<void> registerPrestamo(PrestamoChofer mb);


  Future<void> obtainCoches();

  Future<List<PrestamoChofer>> lstSolicitudesPretamos( int codSucursal, int codEmpEntregadoPor );

  Future<void> actualizarSolicitud( SolicitudChofer mb );

  Future<List<TipoSolicitud>> lstTipoSolicitudes();

}