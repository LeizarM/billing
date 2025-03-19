import 'package:flutter/material.dart';
import 'package:billing/domain/register-depositos/BancoXCuenta.dart';
import 'constants.dart';

class BancoSelector extends StatelessWidget {
  final BancoXCuenta? selectedBanco;
  final List<BancoXCuenta> bancos;
  final Function(BancoXCuenta?) onChanged;

  const BancoSelector({
    Key? key,
    required this.selectedBanco,
    required this.bancos,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<BancoXCuenta>(
      decoration: inputDecoration('Banco', icon: Icons.account_balance),
      value: selectedBanco,
      isExpanded: true,
      menuMaxHeight: 300,
      items: bancos.map((banco) {
        return DropdownMenuItem<BancoXCuenta>(
          value: banco,
          child: Text(
            banco.nombreBanco ?? '',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione un banco' : null,
    );
  }
}
