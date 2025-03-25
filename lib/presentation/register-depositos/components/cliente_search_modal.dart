import 'package:flutter/material.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'constants.dart';

class ClienteSearchModal extends StatefulWidget {
  final List<SocioNegocio> socios;
  final Function(SocioNegocio) onSelect;

  const ClienteSearchModal({
    Key? key,
    required this.socios,
    required this.onSelect,
  }) : super(key: key);

  @override
  ClienteSearchModalState createState() => ClienteSearchModalState();
}

class ClienteSearchModalState extends State<ClienteSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  late List<SocioNegocio> _filteredSocios;

  @override
  void initState() {
    super.initState();
    _filteredSocios = widget.socios;
  }

  void _filterSocios(String query) {
    setState(() {
      _filteredSocios = widget.socios.where((socio) {
        final nombre = socio.nombreCompleto?.toLowerCase() ?? '';
        final codigo = socio.codCliente?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return nombre.contains(search) || codigo.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(kPadding),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 50,
            margin: const EdgeInsets.only(bottom: kFieldSpacing),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar cliente...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSocios('');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
            onChanged: _filterSocios,
          ),
          const SizedBox(height: kFieldSpacing),
          Expanded(
            child: _filteredSocios.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredSocios.length,
                    itemBuilder: (context, index) {
                      final socio = _filteredSocios[index];
                      return InkWell(
                        onTap: () => widget.onSelect(socio),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.person, color: Colors.teal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      socio.nombreCompleto ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Código: ${socio.codCliente}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No se encontraron clientes')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Función para mostrar el modal
void showClienteSearch(
  BuildContext context,
  List<SocioNegocio> socios,
  Function(SocioNegocio) onSelect,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return ClienteSearchModal(
        socios: socios,
        onSelect: (socio) {
          onSelect(socio);
          Navigator.pop(context); // Asegurar que el modal se cierre después de la selección
        },
      );
    },
  );
}
