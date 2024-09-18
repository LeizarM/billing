import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../application/auth/local_storage_service.dart';
import '../../application/sync/sync_service.dart';
import '../../infrastructure/persistence/database_helper.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

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

  // Definimos los colores principales usando Material 3
  final Color primaryColor = Color(0xFF6A1B9A); // Morado
  final Color accentColor = Color(0xFF388E3C); // Verde
  final Color backgroundColor = Color(0xFFF5F5F5); // Gris claro

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
          title: Text('Error', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: primaryColor)),
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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  elevation: 4,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    controller: _searchController,
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      hintText: 'Buscar por código o descripción',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      )
                    : groupedItems.isEmpty
                        ? Center(
                            child: Text(
                              'No se encontraron items',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadItems,
                            child: ListView.separated(
                              physics: BouncingScrollPhysics(),
                              itemCount: groupedItems.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (context, index) {
                                final item =
                                    groupedItems.values.elementAt(index);
                                return GestureDetector(
                                  onTap: () => _navigateToAvailability(
                                    context,
                                    _getGroupedItems(
                                        item['codArticulo'].toString()),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['datoArt']?.toString() ??
                                              'Sin nombre',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Código: ${item['codArticulo']}',
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                            Text(
                                              'Disponible: ${numberFormat.format(item['disponible'])}',
                                              style: TextStyle(
                                                  color: accentColor,
                                                  fontWeight: FontWeight.bold),
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: accentColor,
            onPressed: _forceSyncFromServer,
            tooltip: 'Sincronizar con SAP',
            heroTag: 'syncButton',
            child: const Icon(Icons.sync, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () {
              _searchController.clear();
              _loadItems();
            },
            tooltip: 'Recargar items',
            heroTag: 'refreshButton',
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
