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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detalles del Item', 
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
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
            Icon(Icons.warning_amber_rounded, size: 72, color: Colors.redAccent.shade700),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 18, color: Colors.redAccent.shade700, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                elevation: 3,
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
      physics: const BouncingScrollPhysics(),
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
          const SizedBox(height: 16),
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
      elevation: 3,
      shadowColor: Colors.teal.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_city, color: Colors.teal.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Text('Detalle por Ciudad',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    )),
              ],
            ),
            const SizedBox(height: 20),
            ...cityTotals.entries.map((entry) {
              final String city = entry.key;
              final double total = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(city, style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_formatNumber(total),
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          )),
                    ),
                  ],
                ),
              );
            }).toList(),
            Divider(thickness: 1.2, height: 32, color: Colors.teal.shade100),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total General:', 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      )),
                  Text(_formatNumber(totalGeneral),
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.teal.shade800,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.lightBlue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.inventory_2_outlined, 
                    color: Colors.indigo.shade700, 
                    size: 30
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        'Código: ${item['codArticulo']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Artículo',
                          style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description, color: Colors.indigo.shade300, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      item['datoArt'],
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
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
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.deepOrange.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.deepOrange.shade100, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2, color: Colors.deepOrange.shade700, size: 24),
              const SizedBox(width: 8),
              Text('DISPONIBILIDADES',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w800,
                  color: Colors.deepOrange.shade800,
                  letterSpacing: 1.0,
                )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...groupedItemsData.entries.map((entry) {
          final items = entry.value;
          final totalDisponible = items.fold<double>(
              0, (sum, item) => sum + (item.disponible ?? 0));
          return Card(
            elevation: 3,
            shadowColor: Colors.blue.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...items.map(_buildStockItem),
                  Divider(thickness: 1.2, height: 24, color: Colors.grey.shade200),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Disponible:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _formatNumber(totalDisponible),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
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
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warehouse_outlined, size: 20, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.whsName}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.whsCode,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('BD: ${item.db}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Text(
                _formatNumber(item.disponible),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricesSection() {
    if (_items == null) return const SizedBox.shrink();
    final groupedItems = _groupItemsByCompany(_items!);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.amber.shade200, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, color: Colors.amber.shade800, size: 24),
              const SizedBox(width: 8),
              Text('PRECIOS Y CONDICIONES',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w800,
                  color: Colors.amber.shade800,
                  letterSpacing: 1.0,
                )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...groupedItems.entries.map((entry) =>
            _buildCompanyPriceInfo(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildCompanyPriceInfo(String company, List<Map<String, dynamic>> companyItems) {
    final compName = _getCompanyName(company);
    companyItems.sort((a, b) => b['listaPrecio'].compareTo(a['listaPrecio']));
    return Card(
      elevation: 3,
      shadowColor: Colors.purple.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.business, size: 20, color: Colors.purple.shade700),
                ),
                const SizedBox(width: 12),
                Text(compName,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800)),
              ],
            ),
            Divider(thickness: 1.2, height: 24, color: Colors.purple.shade50),
            ...companyItems.map((item) => Card(
                  elevation: 0,
                  color: Colors.grey.shade50,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.list_alt, size: 18, color: Colors.purple.shade300),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lista ${item['listaPrecio']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple.shade800,
                                  ),
                                ),
                                Text(
                                  '(${item['condicionPrecio']})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade100),
                          ),
                          child: Text(
                            '${numberFormat.format(item['precio'])} ${item['moneda']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.purple.shade700),
                          ),
                        ),
                      ],
                    ),
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
      shadowColor: Colors.lime.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info_outline, color: Colors.indigo.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Text('Información Adicional:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
              ],
            ),
            Divider(thickness: 1.2, height: 32, color: Colors.lime.shade200),
            
            _buildInfoRow('UTM:', utm),
            const SizedBox(height: 16),
            _buildInfoRow('Código de Familia:', familyCode),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lime.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              value, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo.shade600,
              )
            ),
          ),
        ],
      ),
    );
  }
}