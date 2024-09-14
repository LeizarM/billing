class Vista {
  int? codVista;
  int? codVistaPadre;
  String? direccion;
  String? titulo;
  String? descripcion;
  String? imagen;
  int? esRaiz;
  int? autorizar;
  int? audUsuarioI;
  int? fila;
  List<Vista>? items = [];
  String? label;
  int? tieneHijo;
  String? routerLink;
  String? icon;

  Vista({
    required this.codVista,
    required this.codVistaPadre,
    required this.direccion,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.esRaiz,
    required this.autorizar,
    required this.audUsuarioI,
    required this.fila,
    required List<Vista>? items,
    required this.label,
    required this.tieneHijo,
    required this.routerLink,
    required this.icon,
  });

  factory Vista.fromJson(Map<String, dynamic> json) => Vista(
        codVista: json["codVista"],
        codVistaPadre: json["codVistaPadre"],
        direccion: json["direccion"],
        titulo: json["titulo"],
        descripcion: json["descripcion"],
        imagen: json["imagen"],
        esRaiz: json["esRaiz"],
        autorizar: json["autorizar"],
        audUsuarioI: json["audUsuarioI"],
        fila: json["fila"],
        items: json["items"] != null
            ? List<Vista>.from(json["items"].map((x) => Vista.fromJson(x)))
            : null,
        label: json["label"],
        tieneHijo: json["tieneHijo"],
        routerLink: json["routerLink"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "codVista": codVista,
        "codVistaPadre": codVistaPadre,
        "direccion": direccion,
        "titulo": titulo,
        "descripcion": descripcion,
        "imagen": imagen,
        "esRaiz": esRaiz,
        "autorizar": autorizar,
        "audUsuarioI": audUsuarioI,
        "fila": fila,
        "items": [],
        "label": label,
        "tieneHijo": tieneHijo,
        "routerLink": routerLink,
        "icon": icon,
      };
}
