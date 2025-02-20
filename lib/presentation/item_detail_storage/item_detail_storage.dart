import 'dart:async';

import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/item/item_services.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ItemDetailStorgate extends StatefulWidget {
  final List<Map<String, dynamic>>? items;

  const ItemDetailStorgate({Key? key, this.items}) : super(key: key);

  @override
  State<ItemDetailStorgate> createState() => _ItemDetailStorgateState();
}

class _ItemDetailStorgateState extends State<ItemDetailStorgate> {
  final ArticuloPrecioDisponibleService _obtenerArticuloXAlmacen =
      ArticuloPrecioDisponibleService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final NumberFormat numberFormat = NumberFormat("#,##0.00");

  Login? _userData;
  Map<String, List<dynamic>> groupedItemsData = {};
  List<Map<String, dynamic>>? _items;
  String? companyName;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _items ??= args?['companyItems'] as List<Map<String, dynamic>>?;
      companyName = args?['companyName'] as String?;

      if (_items == null || _items!.isEmpty) {
        throw Exception('No hay información disponible de los ítems');
      }

      _userData = await _localStorageService.getUser();
      if (_userData == null) {
        throw Exception('No se pudo obtener la información del usuario');
      }

      // Para cada ítem, agrupa la disponibilidad en función del código.
      for (var item in _items!) {
        final codArticulo = item['codArticulo'] as String?;
        if (codArticulo == null) {
          debugPrint('Advertencia: código de artículo no disponible');
          continue;
        }

        try {
          final itemsXStorage = await _obtenerArticuloXAlmacen
              .obtenerArticulosXAlmacen(codArticulo, _userData!.codCiudad)
              .timeout(const Duration(seconds: 10));

          groupedItemsData.putIfAbsent(codArticulo, () => []);
          for (var newItem in itemsXStorage) {
            if (!groupedItemsData[codArticulo]!.any((existingItem) =>
                existingItem?.whsCode == newItem.whsCode &&
                existingItem?.db == newItem.db &&
                existingItem?.disponible == newItem.disponible)) {
              groupedItemsData[codArticulo]!.add(newItem);
            }
          }
        } catch (e) {
          debugPrint('Error al obtener datos para $codArticulo: $e');
        }
      }

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error en _loadData: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar los detalles: ${e.toString()}';
        isLoading = false;
      });
    }
  }

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

  Map<String, List<Map<String, dynamic>>> _groupItemsByCompany(List<Map<String, dynamic>> items) {
    return items.fold<Map<String, List<Map<String, dynamic>>>>(
      {},
      (map, item) {
        final db = item['db'] as String;
        map.putIfAbsent(db, () => []).add(item);
        return map;
      },
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) return numberFormat.format(value);
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Detalles del Item', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 1,
      ),
      body: errorMessage != null
          ? _buildErrorWidget()
          : Skeletonizer(enabled: isLoading, child: _buildContent()),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_outlined, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final Map<String, double> cityTotals = _calculateCityTotals();
    final double totalGeneral = cityTotals.values.fold(0.0, (sum, value) => sum + value);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_items != null && _items!.isNotEmpty) _buildItemHeader(_items!.first),
          const SizedBox(height: 24),
          _buildCityTotalsSection(cityTotals, totalGeneral),
          const SizedBox(height: 24),
          _buildAvailabilitySection(),
          const SizedBox(height: 24),
          _buildPricesSection(),
          const SizedBox(height: 24),
          _buildFamilyCode(),
        ],
      ),
    );
  }

  Map<String, double> _calculateCityTotals() {
    final Map<String, double> cityTotals = {};
    groupedItemsData.forEach((codArticulo, items) {
      for (var item in items) {
        final String city = item.ciudad?.toString() ?? 'Desconocida';
        final double disponible = (item.disponible as num?)?.toDouble() ?? 0.0;
        cityTotals.update(city, (value) => value + disponible, ifAbsent: () => disponible);
      }
    });
    return cityTotals;
  }

  Widget _buildCityTotalsSection(Map<String, double> cityTotals, double totalGeneral) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.location_city, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Text('Detalle por Ciudad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...cityTotals.entries.map((entry) {
              final String city = entry.key;
              final double total = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(city, style: const TextStyle(fontSize: 16)),
                    Text(_formatNumber(total),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
            const Divider(thickness: 1.2, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total General:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_formatNumber(totalGeneral),
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(Map<String, dynamic> item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade50, Colors.lightBlue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'Código: ${item['codArticulo']}',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    item['datoArt'],
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inventory, color: Colors.deepOrange, size: 24),
            SizedBox(width: 8),
            Text('DISPONIBILIDADES',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        ...groupedItemsData.entries.map((entry) {
          final items = entry.value;
          final totalDisponible = items.fold<double>(
              0, (sum, item) => sum + (item.disponible ?? 0));
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...items.map(_buildStockItem),
                  const Divider(thickness: 1.2, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Disponible:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        _formatNumber(totalDisponible),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStockItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.whsName} (${item.whsCode})',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.storage, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Base de Datos: ${item.db}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _formatNumber(item.disponible),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPricesSection() {
    if (_items == null) return const SizedBox.shrink();
    final groupedItems = _groupItemsByCompany(_items!);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text('PRECIOS Y CONDICIONES',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...groupedItems.entries.map((entry) =>
                _buildCompanyPriceInfo(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyPriceInfo(String company, List<Map<String, dynamic>> companyItems) {
    final compName = _getCompanyName(company);
    companyItems.sort((a, b) => b['listaPrecio'].compareTo(a['listaPrecio']));
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(compName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const Divider(thickness: 1.2, height: 24),
            ...companyItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.list_alt, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                              'Lista ${item['listaPrecio']} (${item['condicionPrecio']})',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      Text(
                        '${numberFormat.format(item['precio'])} ${item['moneda']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCode() {
    final familyCode = _items != null && _items!.isNotEmpty
        ? _items!.first['codigoFamilia']?.toString() ?? 'N/A'
        : 'N/A';
    final utm = _items != null && _items!.isNotEmpty
        ? _items!.first['utm']?.toString() ?? 'N/A'
        : 'N/A';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lime.shade50, Colors.lime.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.indigo, size: 24),
                SizedBox(width: 8),
                Text('Información Adicional:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(thickness: 1.2, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('UTM:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(utm, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(thickness: 1.2, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Código de Familia:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(familyCode, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}