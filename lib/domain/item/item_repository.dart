import 'package:billing/domain/item/item.dart';

abstract class ArticuloPrecioDisponibleRepository {
  Future<List<ArticuloPrecioDisponible>> obtenerArticulosXAlmacen( String codArticulo, int codCiudad );
}
