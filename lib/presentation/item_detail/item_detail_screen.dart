import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemDetailScreen({Key? key, required this.items}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final firstItem = items.first;
    final groupedItems = _groupItemsByCompany(items);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Fondo dinámico con gradiente y efecto parallax
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Detalles del Item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade300,
                      Colors.deepPurple.shade900,
                    ],
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
                  _buildItemHeader(firstItem),
                  const SizedBox(height: 24),
                  ...groupedItems.entries.map((entry) =>
                      _buildCompanyInfo(context, entry.key, entry.value)),
                  const SizedBox(height: 24),
                  _buildAvailabilityButton(context),
                  const SizedBox(height: 24),
                  _buildCommonInfo(firstItem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader(Map<String, dynamic> item) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del código con ícono distintivo
            Row(
              children: [
                const Icon(Icons.confirmation_number, color: Colors.deepOrange, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    'Código: ${item['codArticulo']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Descripción del item con ícono
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, color: Colors.blueGrey, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    item['datoArt'],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context, String company, List<Map<String, dynamic>> companyItems) {
    final companyName = _getCompanyName(company);
    // Ordenar por lista de precios (de mayor a menor)
    companyItems.sort((a, b) => b['listaPrecio'].compareTo(a['listaPrecio']));
    final numberFormat = NumberFormat('#,##0.00');

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade50, Colors.lightBlue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ícono de empresa
            Row(
              children: [
                Icon(Icons.business, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1.2, height: 24),
            // Títulos de columnas con estilo
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lista de Precios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Precio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Detalle de precios, cada fila con icono pequeña
            ...companyItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('Lista ${item['listaPrecio']}:'),
                        ],
                      ),
                      Text(
                        '${numberFormat.format(item['precio'])} ${item['moneda']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/item-detail-storage',
            arguments: {
              'companyItems': items,
              'companyName': 'Todas las empresas',
            },
          );
        },
        icon: const Icon(Icons.visibility_outlined),
        label: const Text('Detalle de Disponibilidad'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6,
          shadowColor: Colors.deepPurpleAccent,
        ),
      ),
    );
  }

  Widget _buildCommonInfo(Map<String, dynamic> item) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con ícono para la información adicional
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.indigo, size: 24),
                SizedBox(width: 8),
                Text(
                  'Información Adicional:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Código de Familia', '${item['codigoFamilia']}', Icons.category),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(iconData, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}