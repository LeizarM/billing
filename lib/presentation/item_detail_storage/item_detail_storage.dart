import 'dart:async';

import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/item/item_services.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/presentation/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailStorgate extends StatefulWidget {
  const ItemDetailStorgate({super.key});

  @override
  State<ItemDetailStorgate> createState() => _ItemDetailStorgateState();
}

class _ItemDetailStorgateState extends State<ItemDetailStorgate> {
  final ArticuloPrecioDisponibleService _obtenerArticuloXAlmacen =
      ArticuloPrecioDisponibleService();
  final LocalStorageService _localStorageService = LocalStorageService();
  Login? _userData;
  Map<String, List<dynamic>> groupedItemsData = {};
  String? companyName;
  bool isLoading = true;
  String? errorMessage;
  final NumberFormat numberFormat = NumberFormat("#,##0.00");

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null) {
        throw Exception('No se recibieron argumentos');
      }

      companyName = args['companyName'] as String?;
      final companyItems = args['companyItems'] as List<dynamic>?;

      if (companyItems == null || companyItems.isEmpty) {
        throw Exception('No hay información disponible de los ítems');
      }

      groupedItemsData.clear();
      for (var item in companyItems) {
        final codArticulo = item['codArticulo'] as String?;
        if (codArticulo == null) {
          print('Advertencia: Código de artículo no disponible para un ítem');
          continue;
        }

        print('Intentando obtener datos para: $codArticulo');
        List<dynamic> itemsXStorge = [];
        _userData = await _localStorageService.getUser();
        debugPrint('El usuario es: $_userData');
        try {
          itemsXStorge = await _obtenerArticuloXAlmacen
              .obtenerArticulosXAlmacen(codArticulo, _userData!.codCiudad)
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          print('Error al obtener datos para $codArticulo: $e');
          continue;
        }

        if (!groupedItemsData.containsKey(codArticulo)) {
          groupedItemsData[codArticulo] = [];
        }

        for (var newItem in itemsXStorge) {
          if (!groupedItemsData[codArticulo]!.any((existingItem) =>
              existingItem.whsCode == newItem.whsCode &&
              existingItem.db == newItem.db &&
              existingItem.disponible == newItem.disponible)) {
            groupedItemsData[codArticulo]!.add(newItem);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
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
        title: const Text('Detalles de Stock'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? _buildErrorWidget()
                : _buildContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(initialIndex: 1),
            ),
          );
        },
        label: const Text('Inicio'),
        icon: const Icon(Icons.home_filled),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (companyName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  companyName!,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            if (groupedItemsData.isEmpty)
              const Center(
                child: Text(
                  'No hay información disponible',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
            else
              _buildGroupedItemsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedItemsData.length,
      itemBuilder: (context, index) {
        final codArticulo = groupedItemsData.keys.elementAt(index);
        final items = groupedItemsData[codArticulo]!;
        final totalDisponible = _calculateTotalDisponible(items);

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  'Código: $codArticulo',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  items.first.datoArt,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Disponibilidades:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                ...items.map((item) => _buildStockItem(item, context)),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Disponible:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatNumber(totalDisponible),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockItem(dynamic item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.whsName} (${item.whsCode})',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Base de Datos: ${item.db}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _formatNumber(item.disponible),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalDisponible(List<dynamic> items) {
    return items.fold<double>(0, (sum, item) => sum + (item.disponible ?? 0));
  }

  String _formatNumber(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) return numberFormat.format(value);
    return value.toString();
  }
}
