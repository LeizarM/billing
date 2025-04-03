import 'package:billing/domain/fuel-control/FuelControl.dart';

abstract class FuelControlRepository {
  // Método para registrar un nuevo control de combustible
  Future<void> registerFuelControl(CombustibleControl mb);

  // Método para obtener los controles de combustible por sucursal y empleado
  Future<List<CombustibleControl>> getCars();

  
  
}