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
  List<Vista>? items;
  String? label;
  int? tieneHijo;
  String? routerLink;
  String? icon;

  Vista({
    this.codVista,
    this.codVistaPadre,
    this.direccion,
    this.titulo,
    this.descripcion,
    this.imagen,
    this.esRaiz,
    this.autorizar,
    this.audUsuarioI,
    this.fila,
    this.items,
    this.label,
    this.tieneHijo,
    this.routerLink,
    this.icon,
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
        "items": items?.map((x) => x.toJson()).toList(),
        "label": label,
        "tieneHijo": tieneHijo,
        "routerLink": routerLink,
        "icon": icon,
      };
}
