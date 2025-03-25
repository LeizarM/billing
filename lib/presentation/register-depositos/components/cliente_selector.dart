import 'package:flutter/material.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'cliente_search_modal.dart';
import 'constants.dart';

class ClienteSelector extends StatelessWidget {
  final SocioNegocio? selectedCliente;
  final List<SocioNegocio> clientes;
  final Function(SocioNegocio) onSelect;
  final bool isEnabled;
  final bool? hasError;

  const ClienteSelector({
    Key? key,
    required this.selectedCliente,
    required this.clientes,
    required this.onSelect,
    this.isEnabled = true,
    this.hasError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the selected client is "Todos"
    final isTodos = selectedCliente != null && 
                   selectedCliente!.codCliente == "" && 
                   selectedCliente!.nombreCompleto == "Todos";
                   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: !isEnabled ? null : () => showClienteSearch(context, clientes, onSelect),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError == true 
                    ? Theme.of(context).colorScheme.error 
                    : Colors.grey.shade400
              ),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedCliente == null
                        ? 'Seleccione un cliente'
                        : isTodos
                            ? 'Todos'
                            : '${selectedCliente!.codCliente} - ${selectedCliente!.nombreCompleto}',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedCliente == null
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: !isEnabled
                      ? Colors.grey.shade400
                      : Colors.teal,
                ),
              ],
            ),
          ),
        ),
        if (hasError == true)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Seleccione un cliente',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
