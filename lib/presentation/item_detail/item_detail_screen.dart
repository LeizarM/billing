import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemDetailScreen({super.key, required this.items});

  String _getCompanyName(String db) {
    switch (db) {
      case 'IPX':
        return 'Impexpap';
      case 'ESP':
        return 'Esppapel';
      default:
        return db;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = items.first;
    final groupedItems = _groupItemsByCompany(items);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Detalles del Item'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.indigo],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            'Código: ${firstItem['codArticulo']}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            'Descripción: ${firstItem['datoArt']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...groupedItems.entries
                      .map((entry) => _buildCompanyInfo(entry.key, entry.value))
                      .toList(),
                  const SizedBox(height: 16),
                  _buildCommonInfo(firstItem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupItemsByCompany(
      List<Map<String, dynamic>> items) {
    return items.fold<Map<String, List<Map<String, dynamic>>>>(
      {},
      (map, item) {
        final db = item['db'] as String;
        if (!map.containsKey(db)) {
          map[db] = [];
        }
        map[db]!.add(item);
        return map;
      },
    );
  }

  Widget _buildCompanyInfo(
      String company, List<Map<String, dynamic>> companyItems) {
    final companyName = _getCompanyName(company);
    final totalDisponible = companyItems.first['disponible'];
    final unidadMedida = companyItems.first['unidadMedida'];
    companyItems.sort((a, b) => b['listaPrecio'].compareTo(a['listaPrecio']));

    // Crea un formateador de números
    final numberFormat = NumberFormat('#,##0.00');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lista de Precios',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Precio',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ...companyItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lista ${item['listaPrecio']}'),
                      Text(
                        '${numberFormat.format(item['precio'])} ${item['moneda']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            Text(
              'Total disponible: $totalDisponible $unidadMedida',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonInfo(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información Adicional:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Código de Familia', '${item['codigoFamilia']}'),
            /* _buildDetailRow('Código de Ciudad', '${item['codCiudad']}'),
            _buildDetailRow('Código Grupo Familia SAP', '${item['codGrpFamiliaSap']}'),
            _buildDetailRow('Ruta', '${item['ruta']}'), */
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
