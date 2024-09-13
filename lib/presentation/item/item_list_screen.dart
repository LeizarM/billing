import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../application/auth/local_storage_service.dart';
import '../../application/sync/sync_service.dart';
import '../../infrastructure/persistence/database_helper.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final LocalStorageService _localStorageService = LocalStorageService();
  final SyncService _syncService = SyncService();
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
    try {
      final items = await _databaseHelper.getItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar items: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error al cargar los items');
    }
  }

  Future<void> _searchItems(String query) async {
    setState(() => _isLoading = true);
    try {
      final items = await _databaseHelper.searchItems(query: query);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al buscar items: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error al buscar los items');
    }
  }

  Future<void> _forceSyncFromServer() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _localStorageService.getUser();
      if (userData != null) {
        await _syncService.syncProductos(userData.token, userData.codCiudad);
        await _loadItems(); // Recargar los items después de la sincronización
      } else {
        throw Exception('No se encontraron datos de usuario');
      }
    } catch (e) {
      print('Error al sincronizar: $e');
      _showErrorDialog('Error al sincronizar con el servidor');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: LinearProgressIndicator(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cargando...',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  )
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _forceSyncFromServer,
            tooltip: 'Sincronizar con SAP',
            heroTag: null,
            child: const Icon(Icons.sync),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _searchController.clear();
              _loadItems();
            },
            tooltip: 'Recargar items',
            heroTag: null,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
