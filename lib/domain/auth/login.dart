class Login {
  final String token;
  final String bearer;
  final String nombreCompleto;
  final String cargo;
  final String tipoUsuario;
  final int codUsuario;
  final int codEmpleado;
  final int codEmpresa;
  final int codCiudad;
  final String login;
  final List<Authority> authorities;

  Login({
    required this.token,
    required this.bearer,
    required this.nombreCompleto,
    required this.cargo,
    required this.tipoUsuario,
    required this.codUsuario,
    required this.codEmpleado,
    required this.codEmpresa,
    required this.codCiudad,
    required this.login,
    required this.authorities,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      token: json['token'],
      bearer: json['bearer'],
      nombreCompleto: json['nombreCompleto'],
      cargo: json['cargo'],
      tipoUsuario: json['tipoUsuario'],
      codUsuario: json['codUsuario'],
      codEmpleado: json['codEmpleado'],
      codEmpresa: json['codEmpresa'],
      codCiudad: json['codCiudad'],
      login: json['login'],
      authorities: (json['authorities'] as List)
          .map((a) => Authority.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'bearer': bearer,
      'nombreCompleto': nombreCompleto,
      'cargo': cargo,
      'tipoUsuario': tipoUsuario,
      'codUsuario': codUsuario,
      'codEmpleado': codEmpleado,
      'codEmpresa': codEmpresa,
      'codCiudad': codCiudad,
      'login': login,
      'authorities': authorities.map((a) => a.toJson()).toList(),
    };
  }
}

class Authority {
  final String authority;

  Authority({required this.authority});

  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(authority: json['authority']);
  }

  Map<String, dynamic> toJson() {
    return {'authority': authority};
  }
}
