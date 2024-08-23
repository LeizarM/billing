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
              .timeout(const Duration(
                  seconds: 10)); // Añadimos un timeout de 10 segundos
        } catch (e) {
          continue; // Continuamos con el siguiente ítem si hay un error
        }

        if (!groupedItemsData.containsKey(codArticulo)) {
          groupedItemsData[codArticulo] = [];
        }

        // Eliminar duplicados
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(
                  initialIndex: 1), // Iniciar en la página de Items
            ),
          );
        },
        tooltip: 'Inicio',
        child: const Icon(Icons.home_filled),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
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
            if (groupedItemsData.isEmpty)
              const Center(child: Text('No hay información disponible'))
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
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText('Código: $codArticulo',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SelectableText('Descripción: ${items.first.datoArt}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const SelectableText('Disponibilidades:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText('${item.whsName} (${item.whsCode})',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          SelectableText(
                              'Disponible: ${_formatNumber(item.disponible)}'),
                          SelectableText('Base de Datos: ${item.db}'),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                SelectableText(
                    'Total Disponible: ${_formatNumber(totalDisponible)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
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
