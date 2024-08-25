import 'dart:async';

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
  final NumberFormat numberFormat = NumberFormat('#,##0.00');

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

  void _navigateToAvailability(
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
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por código o nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : groupedItems.isEmpty
                    ? const Center(child: Text('No se encontraron items'))
                    : ListView.separated(
                        itemCount: groupedItems.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = groupedItems.values.elementAt(index);
                          return ListTile(
                            title: Text(
                              item['datoArt']?.toString() ?? 'Sin nombre',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Código: ${item['codArticulo']}'),
                                Text(
                                    'Disponible: ${numberFormat.format(item['disponible'])}'),
                              ],
                            ),
                            onTap: () => _navigateToAvailability(
                              context,
                              _getGroupedItems(item['codArticulo'].toString()),
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
