import 'package:flutter/material.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'constants.dart';

class EmpresaSelector extends StatelessWidget {
  final Empresa? selectedEmpresa;
  final List<Empresa> empresas;
  final Function(Empresa?) onChanged;
  final String? errorText;

  const EmpresaSelector({
    Key? key,
    required this.selectedEmpresa,
    required this.empresas,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Empresa>(
      decoration: inputDecoration('Empresa', icon: Icons.business),
      value: selectedEmpresa,
      items: empresas.map((empresa) {
        return DropdownMenuItem<Empresa>(
          value: empresa,
          child: Text(empresa.nombre ?? ''),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione una empresa' : null,
    );
  }
}
