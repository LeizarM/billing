import 'dart:async';

import 'package:billing/presentation/item_detail/item_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../infrastructure/persistence/database_helper.dart';

class ItemsScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final NumberFormat numberFormat = NumberFormat('#,##0.00', 'es_ES');

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchItems(_searchController.text);
    });
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _databaseHelper.getItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _searchItems(String query) async {
    setState(() => _isLoading = true);
    final items = await _databaseHelper.searchItems(query: query);
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getGroupedItems(String codArticulo) {
    return _items
        .where((item) => item['codArticulo'].toString() == codArticulo)
        .toList();
  }

  void _showPrices(BuildContext context, List<Map<String, dynamic>> items) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Precios'),
          content: SingleChildScrollView(
            child: ListBody(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Lista ${item['listaPrecio']}'),
                            Text(
                              '${numberFormat.format(item['precio'])} ${item['moneda']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAvailability(
      BuildContext context, List<Map<String, dynamic>> items) {
    Navigator.pushNamed(
      context,
      '/item-detail-storage',
      arguments: {
        'companyItems': items,
        'companyName': 'Todas las empresas',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _items.fold<Map<String, Map<String, dynamic>>>(
      {},
      (map, item) {
        final codArticulo = item['codArticulo'].toString();
        if (!map.containsKey(codArticulo)) {
          map[codArticulo] = item;
        }
        return map;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por código o nombre',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : groupedItems.isEmpty
                    ? const Center(child: Text('No se encontraron items'))
                    : ListView.builder(
                        itemCount: groupedItems.length,
                        itemBuilder: (context, index) {
                          final item = groupedItems.values.elementAt(index);
                          final groupedItemsList =
                              _getGroupedItems(item['codArticulo'].toString());
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['datoArt']?.toString() ?? 'Sin nombre',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Código: ${item['codArticulo']}'),
                                  Text(
                                      'Disponible: ${numberFormat.format(item['disponible'])}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        /* onPressed: () => _showPrices( context, groupedItemsList ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          minimumSize: const Size(100, 30),
                                        ), */
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ItemDetailScreen(
                                                items: _getGroupedItems(
                                                    item['codArticulo']
                                                        .toString()),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Ver Precios'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _showAvailability(
                                            context, groupedItemsList),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          minimumSize: const Size(100, 30),
                                        ),
                                        child: const Text('Disponibilidad'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _searchController.clear();
          _loadItems();
        },
        tooltip: 'Recargar items',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
