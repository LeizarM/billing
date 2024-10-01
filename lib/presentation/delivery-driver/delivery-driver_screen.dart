import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/application/delivery-driver/location_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:billing/presentation/delivery-driver/widgets/customLoadingIndicator.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DeliveryDriverScreen extends StatefulWidget {
  const DeliveryDriverScreen({super.key});

  @override
  State<DeliveryDriverScreen> createState() => _DeliveryDriverScreenState();
}

class _DeliveryDriverScreenState extends State<DeliveryDriverScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DeliveryDriverService _deliveryDriverService = DeliveryDriverService();
  final LocationService _locationService = LocationService();
  List<GroupedDelivery>? _groupedDeliveries;
  bool _isLoading = true;
  bool _isGettingLocation = false;
  Login? userData;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      userData = await _localStorageService.getUser();
      if (userData != null) {
        final deliveries =
            await _deliveryDriverService.obtainDelivery(userData!.codEmpleado);
        _groupDeliveries(deliveries);
      } else {
        print('User data or employee code is null');
      }
    } catch (e) {
      print('Error loading deliveries: $e');
      _showErrorSnackBar('Error al cargar las entregas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupDeliveries(List<DeliveryDriver> deliveries) {
    final grouped = groupBy(deliveries, (DeliveryDriver d) => d.docEntry);
    _groupedDeliveries = grouped.entries.map((entry) {
      final items = entry.value;
      final db = items.first.db!;
      return GroupedDelivery(
        docEntry: entry.key!,
        cardName: items.first.cardName!,
        docDate: DateTime.parse(items.first.docDate.toString()),
        addressEntregaMat: items.first.addressEntregaMat!,
        items: items,
        db: db,
      );
    }).toList();
  }

  Future<void> _markAsDelivered(GroupedDelivery delivery) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar entrega',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            '¿Estás seguro de que quieres marcar esta entrega como completada?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('Confirmar'),
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isGettingLocation = true;
      });

      try {
        bool permissionGranted =
            await _locationService.checkAndRequestLocationPermissions(context);
        if (!permissionGranted) {
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }

        Position? position = await _locationService.getCurrentPosition();
        if (position == null) {
          throw Exception('No se pudo obtener la posición.');
        }

        String address = await _locationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        String currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        await _saveDeliveryData(
          docEntry: delivery.docEntry,
          db: delivery.db,
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
          dateTime: currentDateTime,
          audUsuario: userData!.codUsuario,
        );

        setState(() {
          delivery.isDelivered = true;
        });

        await _loadDeliveries();

        _showSuccessSnackBar('Entrega marcada como completada');
      } catch (e) {
        print('Error al marcar como entregada: $e');
        _showErrorSnackBar('Error: $e');
      } finally {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _saveDeliveryData({
    required int docEntry,
    required String db,
    required double latitude,
    required double longitude,
    required String address,
    required String dateTime,
    required int audUsuario,
  }) async {
    try {
      await _deliveryDriverService.saveDeliveryData(
        docEntry: docEntry,
        db: db,
        latitude: latitude,
        longitude: longitude,
        address: address,
        dateTime: dateTime,
        audUsuario: audUsuario,
      );
      print('Datos de la entrega guardados correctamente.');
    } catch (e) {
      print('Error al guardar los datos de la entrega: $e');
      _showErrorSnackBar('Error al guardar los datos de la entrega');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas Pendientes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveries,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isGettingLocation)
            const CustomLoadingIndicator(message: 'Guardando...'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_groupedDeliveries == null || _groupedDeliveries!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay entregas pendientes',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveries,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groupedDeliveries!.length,
        itemBuilder: (context, index) {
          final groupedDelivery = _groupedDeliveries![index];
          return _buildDeliveryCard(groupedDelivery);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(GroupedDelivery delivery) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: delivery.isDelivered
                  ? Colors.green
                  : Theme.of(context).primaryColor,
              radius: 25,
              child: Icon(
                delivery.isDelivered ? Icons.check : Icons.local_shipping,
                color: Colors.white,
              ),
            ),
            title: Text(
              delivery.cardName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(delivery.docDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dirección: ${delivery.addressEntregaMat}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total de productos: ${delivery.items.length}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text('Detalles de productos',
                style: TextStyle(fontWeight: FontWeight.w500)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...delivery.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(item.dscription!,
                                      style: const TextStyle(fontSize: 14))),
                              Text('Cantidad: ${item.quantity}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          if (!delivery.isDelivered)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Marcar como entregado',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () => _markAsDelivered(delivery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
