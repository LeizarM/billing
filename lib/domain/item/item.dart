import 'package:isar/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String codArticulo;

  late String datoArt;
  late int listaPrecio;
  late double precio;
  late String moneda;
  late String codigoFamilia;
  late int disponible;
  late String unidadMedida;
  late int codCiudad;
  late String codGrpFamiliaSap;
  late String ruta;
  late String db;
}
