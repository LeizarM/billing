// lib/presentation/screens/items_screen.dart
import 'dart:async';

import 'package:billing/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../application/auth/local_storage_service.dart';
import '../../application/sync/sync_service.dart';
import '../../infrastructure/persistence/database_helper.dart';

// Constantes de diseño
const double kPadding = 16.0;
const double kBorderRadius = 12.0;
const double kItemSpacing = 12.0;

// Tema de colores moderno
class AppTheme {
  static const Color primaryColor = Color(0xFF2962FF); // Azul más vibrante
  static const Color secondaryColor = Color(0xFF00BFA5); // Verde azulado
  static const Color backgroundColor = Color(0xFFF8F9FA); // Gris muy claro
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color errorColor = Color(0xFFE53935);
  
  // Estilos de texto
  static const TextStyle headingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: textSecondaryColor,
  );
}

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends TokenAwareState<ItemsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final LocalStorageService _localStorageService = LocalStorageService();
  final SyncService _syncService = SyncService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  bool _isSyncing = false;
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
      _showErrorSnackBar('Error al cargar los items');
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
      _showErrorSnackBar('Error al buscar los items');
    }
  }

  Future<void> _forceSyncFromServer() async {
    if (!mounted || _isSyncing) return;
    
    setState(() {
      _isSyncing = true;
    });
    
    try {
      final userData = await _localStorageService.getUser();
      if (userData != null) {
        await _syncService.syncProductos(userData.token, userData.codCiudad);
        await _loadItems(); // Recargar los items después de la sincronización
        if (mounted) {
          _showSuccessSnackBar('Sincronización completada');
        }
      } else {
        throw Exception('No se encontraron datos de usuario');
      }
    } catch (e) {
      print('Error al sincronizar: $e');
      if (mounted) {
        _showErrorSnackBar('Error al sincronizar con el servidor');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(kPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(kPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }


  List<Map<String, dynamic>> _getGroupedItems(String codArticulo) {
    return _items
        .where((item) => item['codArticulo'].toString() == codArticulo)
        .toList();
  }

  void _navigateToAvailability(
      BuildContext context, List<Map<String, dynamic>> items) {
    HapticFeedback.lightImpact();
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
        title: const Text(
          'Inventario',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: _isSyncing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _forceSyncFromServer,
            tooltip: 'Sincronizar con SAP',
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildItemsCount(groupedItems.length),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : groupedItems.isEmpty
                      ? _buildEmptyState()
                      : _buildItemsList(groupedItems),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.secondaryColor,
        onPressed: () {
          _searchController.clear();
          _loadItems();
        },
        tooltip: 'Recargar items',
        child: const Icon(Icons.refresh, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(kBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(kBorderRadius),
        color: Colors.white,
        child: TextField(
          controller: _searchController,
          cursorColor: AppTheme.primaryColor,
          decoration: InputDecoration(
            hintText: 'Buscar por código o descripción',
            hintStyle: AppTheme.bodyStyle,
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _searchItems('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildItemsCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPadding, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count artículos encontrados',
            style: AppTheme.captionStyle,
          ),
          const Spacer(),
          if (_isSyncing)
            Row(
              children: const [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Sincronizando...',
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando artículos...',
            style: AppTheme.bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron artículos',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Intente con otra búsqueda o sincronice con el servidor',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _forceSyncFromServer,
            icon: const Icon(Icons.sync),
            label: const Text('Sincronizar ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(Map<String, Map<String, dynamic>> groupedItems) {
    return RefreshIndicator(
      onRefresh: _loadItems,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: groupedItems.length,
        padding: const EdgeInsets.all(kPadding),
        itemBuilder: (context, index) {
          final item = groupedItems.values.elementAt(index);
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final disponible = item['disponible'] ?? 0;
    final isLowStock = disponible <= 10;
    
    return Card(
      margin: const EdgeInsets.only(bottom: kItemSpacing),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _navigateToAvailability(
          context,
          _getGroupedItems(item['codArticulo'].toString()),
        ),
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['datoArt']?.toString() ?? 'Sin nombre',
                          style: AppTheme.subheadingStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código: ${item['codArticulo']}',
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        color: isLowStock ? Colors.orange : AppTheme.secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Disponible: ${numberFormat.format(disponible)}',
                        style: TextStyle(
                          color: isLowStock ? Colors.orange : AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
