import 'package:billing/application/item/item_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailStorgate extends StatefulWidget {
  const ItemDetailStorgate({Key? key}) : super(key: key);

  @override
  State<ItemDetailStorgate> createState() => _ItemDetailStorgateState();
}

class _ItemDetailStorgateState extends State<ItemDetailStorgate> {
  final ArticuloPrecioDisponibleService _obtenerArticuloXAlmacen =
      ArticuloPrecioDisponibleService();
  Map<String, dynamic>? itemData;
  String? companyName;
  bool isLoading = true;
  String? errorMessage;
  final NumberFormat numberFormat = NumberFormat("#,##0.##", "es_ES");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
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
      final companyItems = args['companyItems'] as List<Map<String, dynamic>>?;

      if (companyItems == null || companyItems.isEmpty) {
        throw Exception('No hay información disponible del ítem');
      }

      final codArticulo = companyItems.first['codArticulo'] as String?;
      if (codArticulo == null) {
        throw Exception('Código de artículo no disponible');
      }

      print('Intentando obtener datos para: $codArticulo');
      final itemsXStorge = await _obtenerArticuloXAlmacen
          .obtenerArticulosXAlmacen(codArticulo, 1);

      print('Datos recibidos de obtenerArticulosXAlmacen:');
      print(itemsXStorge);

      if (itemsXStorge.isEmpty) {
        throw Exception('No se recibieron datos del servidor');
      }

      final firstItem = itemsXStorge.first;
      itemData = {
        'codArticulo': firstItem.codArticulo as String? ?? 'N/A',
        'datoArt': firstItem.datoArt as String? ?? 'N/A',
        'disponible': firstItem.disponible as num? ?? 0,
        'whsCode': firstItem.whsCode as String? ?? 'N/A',
        'whsName': firstItem.whsName as String? ?? 'N/A',
        'db': firstItem.db as String? ?? 'N/A',
      };

      print('Datos procesados:');
      print(itemData);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error en _loadData: $e');
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
        title: Text('Detalles de Stock'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (companyName != null) SizedBox(height: 24),
              if (isLoading)
                CircularProgressIndicator()
              else if (errorMessage != null)
                _buildErrorWidget()
              else if (itemData != null)
                _buildItemInfo()
              else
                Text('No hay información disponible'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        Text(
          errorMessage!,
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadData,
          child: Text('Reintentar'),
        ),
      ],
    );
  }

  Widget _buildItemInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${itemData!['codArticulo']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Descripción: ${itemData!['datoArt']}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Disponible: ${itemData!['disponible']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Almacén: ${itemData!['whsName']} (${itemData!['whsCode']})'),
            Text('Base de Datos: ${itemData!['db']}'),
          ],
        ),
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) return numberFormat.format(value);
    return value.toString();
  }
}
