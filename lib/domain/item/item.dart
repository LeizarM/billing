class ArticuloPrecioDisponible {
  String codArticulo;
  String datoArt;
  double listaPrecio;
  double precio;
  String moneda;
  double gramaje;
  double codigoFamilia;
  double disponible;
  String unidadMedida;
  double codCiudad;
  double codGrpFamiliaSap;
  String ruta;
  double audUsuario;
  String db;
  String whsCode;
  String whsName;

  ArticuloPrecioDisponible({
    required this.codArticulo,
    required this.datoArt,
    required this.listaPrecio,
    required this.precio,
    required this.moneda,
    required this.gramaje,
    required this.codigoFamilia,
    required this.disponible,
    required this.unidadMedida,
    required this.codCiudad,
    required this.codGrpFamiliaSap,
    required this.ruta,
    required this.audUsuario,
    required this.db,
    required this.whsCode,
    required this.whsName,
  });

  factory ArticuloPrecioDisponible.fromJson(Map<String, dynamic> json) =>
      ArticuloPrecioDisponible(
        codArticulo: json["codArticulo"],
        datoArt: json["datoArt"],
        listaPrecio: json["listaPrecio"],
        precio: json["precio"],
        moneda: json["moneda"],
        gramaje: json["gramaje"],
        codigoFamilia: json["codigoFamilia"],
        disponible: json["disponible"],
        unidadMedida: json["unidadMedida"],
        codCiudad: json["codCiudad"],
        codGrpFamiliaSap: json["codGrpFamiliaSap"],
        ruta: json["ruta"],
        audUsuario: json["audUsuario"],
        db: json["db"],
        whsCode: json["whsCode"],
        whsName: json["whsName"],
      );

  Map<String, dynamic> toJson() => {
        "codArticulo": codArticulo,
        "datoArt": datoArt,
        "listaPrecio": listaPrecio,
        "precio": precio,
        "moneda": moneda,
        "gramaje": gramaje,
        "codigoFamilia": codigoFamilia,
        "disponible": disponible,
        "unidadMedida": unidadMedida,
        "codCiudad": codCiudad,
        "codGrpFamiliaSap": codGrpFamiliaSap,
        "ruta": ruta,
        "audUsuario": audUsuario,
        "db": db,
        "whsCode": whsCode,
        "whsName": whsName,
      };
}
