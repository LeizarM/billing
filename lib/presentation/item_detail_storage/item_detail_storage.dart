import 'dart:async';

import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/item/item_services.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailStorgate extends StatefulWidget {
  final List<Map<String, dynamic>>? items;

  const ItemDetailStorgate({super.key, this.items});

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

      for (var item in _items!) {
        final codArticulo = item['codArticulo'] as String?;
        if (codArticulo == null) {
          print('Advertencia: Código de artículo no disponible para un ítem');
          continue;
        }

        try {
          final itemsXStorge = await _obtenerArticuloXAlmacen
              .obtenerArticulosXAlmacen(codArticulo, _userData!.codCiudad)
              .timeout(const Duration(seconds: 10));

          if (!groupedItemsData.containsKey(codArticulo)) {
            groupedItemsData[codArticulo] = [];
          }

          for (var newItem in itemsXStorge) {
            if (newItem != null &&
                !groupedItemsData[codArticulo]!.any((existingItem) =>
                    existingItem?.whsCode == newItem.whsCode &&
                    existingItem?.db == newItem.db &&
                    existingItem?.disponible == newItem.disponible)) {
              groupedItemsData[codArticulo]!.add(newItem);
            }
          }
        } catch (e) {
          print('Error al obtener datos para $codArticulo: $e');
        }
      }

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      print('Error en _loadData: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar los detalles: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Item'),
        centerTitle: true,
        elevation: 0,
      ),
      body: errorMessage != null ? _buildErrorWidget() : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final Map<String, double> cityTotals = _calculateCityTotals();
    final double totalGeneral =
        cityTotals.values.fold(0.0, (sum, value) => sum + value);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_items != null && _items!.isNotEmpty)
              isLoading
                  ? _buildSkeletonHeader()
                  : _buildItemHeader(_items!.first),
            const SizedBox(height: 24),
            _buildCityTotalsSection(cityTotals, totalGeneral),
            const SizedBox(height: 24),
            isLoading
                ? _buildSkeletonAvailability()
                : _buildAvailabilitySection(),
            const SizedBox(height: 24),
            isLoading ? _buildSkeletonPrices() : _buildPricesSection(),
            const SizedBox(height: 24),
            _buildFamilyCode(),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTotalsSection(
      Map<String, double> cityTotals, double totalGeneral) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detalle por Ciudad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...cityTotals.entries.map((entry) {
          final String city = entry.key;
          final double total = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(city, style: const TextStyle(fontSize: 16)),
                Text(_formatNumber(total),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total General:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_formatNumber(totalGeneral),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor)),
          ],
        ),
      ],
    );
  }

  Map<String, double> _calculateCityTotals() {
    final Map<String, double> cityTotals = {};

    groupedItemsData.forEach((codArticulo, items) {
      for (var item in items) {
        // Convertir codCiudad a String
        final String city = item.ciudad ?? 'Desconocida';
        // Convertir disponible a double
        final double disponible = (item.disponible as num?)?.toDouble() ?? 0.0;

        if (!cityTotals.containsKey(city)) {
          cityTotals[city] = 0.0;
        }
        cityTotals[city] = cityTotals[city]! + disponible;
      }
    });

    return cityTotals;
  }

  Widget _buildSkeletonHeader() => _buildSkeletonCard([200.0, double.infinity]);

  Widget _buildSkeletonAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 150, height: 24, color: Colors.grey[300]),
        const SizedBox(height: 16),
        for (int i = 0; i < 3; i++)
          _buildSkeletonCard(
              List.filled(3, 0)
                  .map((_) => [double.infinity, 60.0])
                  .expand((e) => e)
                  .toList(),
              bottomPadding: 16),
      ],
    );
  }

  Widget _buildSkeletonPrices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 100, height: 24, color: Colors.grey[300]),
        const SizedBox(height: 16),
        for (int i = 0; i < 2; i++)
          _buildSkeletonCard([150.0, 100.0, 80.0, 100.0, 80.0, 100.0, 80.0],
              bottomPadding: 16),
      ],
    );
  }

  Widget _buildSkeletonCard(List<double> itemWidths,
      {double bottomPadding = 0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: itemWidths
                .map((width) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                          width: width, height: 16, color: Colors.grey[300]),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildItemHeader(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'Código: ${item['codArticulo']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              item['datoArt'],
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
        const Text('DISPONIBILIDADES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...groupedItemsData.entries.map((entry) {
          final items = entry.value;
          final totalDisponible = items.fold<double>(
              0, (sum, item) => sum + (item.disponible ?? 0));

          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...items.map(_buildStockItem),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Disponible:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        _formatNumber(totalDisponible),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStockItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.whsName} (${item.whsCode})',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor),
                ),
                Text('Base de Datos: ${item.db}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(_formatNumber(item.disponible),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPricesSection() {
    if (_items == null) return const SizedBox.shrink();
    final groupedItems = _groupItemsByCompany(_items!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('PRECIOS Y CONDICIONES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...groupedItems.entries
            .map((entry) => _buildCompanyInfo(entry.key, entry.value))
            .toList(),
      ],
    );
  }

  Widget _buildCompanyInfo(
      String company, List<Map<String, dynamic>> companyItems) {
    final companyName = _getCompanyName(company);
    companyItems.sort((a, b) => b['listaPrecio'].compareTo(a['listaPrecio']));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(companyName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor)),
            const Divider(height: 24),
            ...companyItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Lista ${item['listaPrecio']} ( ${item['condicionPrecio']} )'),
                      Text(
                          '${numberFormat.format(item['precio'])} ${item['moneda']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 98, 4, 175))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCode() {
    final familyCode =
        _items?.firstOrNull?['codigoFamilia']?.toString() ?? 'N/A';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información Adicional:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Código de Familia:'),
                Text(familyCode,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
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

  Map<String, List<Map<String, dynamic>>> _groupItemsByCompany(
      List<Map<String, dynamic>> items) {
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
}
