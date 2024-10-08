import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/application/delivery-driver/location_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:billing/presentation/dashboard/dashboard_screen.dart';
import 'package:billing/presentation/delivery-driver/utils/dialogs.dart';
import 'package:billing/presentation/delivery-driver/widgets/customLoadingIndicator.dart';
import 'package:billing/presentation/delivery-driver/widgets/delivery_card.dart';
import 'package:billing/presentation/delivery-driver/widgets/empty_deliveries_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryDriverScreen extends StatefulWidget {
  const DeliveryDriverScreen({Key? key}) : super(key: key);

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
    setState(() => _isLoading = true);
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
      setState(() => _isLoading = false);
    }
  }

  void _groupDeliveries(List<DeliveryDriver> deliveries) {
    final grouped = groupBy(deliveries, (DeliveryDriver d) => d.docEntry);
    _groupedDeliveries = grouped.entries.map((entry) {
      final items = entry.value;
      return GroupedDelivery(
        docEntry: entry.key!,
        cardName: items.first.cardName!,
        docDate: DateTime.parse(items.first.docDate.toString()),
        addressEntregaMat: items.first.addressEntregaMat!,
        items: items,
        db: items.first.db!,
      );
    }).toList();
  }

  Future<void> _markAsDelivered(GroupedDelivery delivery) async {
    bool? confirm = await showConfirmationDialog(context);
    if (confirm != true) return;

    setState(() => _isGettingLocation = true);
    try {
      if (!await _locationService.checkAndRequestLocationPermissions(context)) {
        setState(() => _isGettingLocation = false);
        return;
      }

      Position? position = await _locationService.getCurrentPosition();
      if (position == null) throw Exception('No se pudo obtener la posición.');

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

      setState(() => delivery.isDelivered = true);
      await _loadDeliveries();
      _showSuccessSnackBar('Entrega marcada como completada');
    } catch (e) {
      print('Error al marcar como entregada: $e');
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isGettingLocation = false);
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

  Future<void> _finishDeliveries() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Finalizar Entregas'),
        content:
            const Text('¿Estás seguro de que deseas finalizar las entregas?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isGettingLocation = true);
      try {
        Position? position = await _locationService.getCurrentPosition();
        if (position == null) {
          throw Exception('No se pudo obtener la posición.');
        }
        String address = await _locationService.getAddressFromLatLng(
            position.latitude, position.longitude);
        String currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('deliveriesActive', false);

        // Navegar al DashboardScreen en lugar de DeliveryDriverStartScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const DashboardScreen(
                    initialIndex: 1,
                  )),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        print('Error al finalizar las entregas: $e');
        _showErrorSnackBar('Error al finalizar las entregas: $e');
      } finally {
        setState(() => _isGettingLocation = false);
      }
    }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _finishDeliveries,
        label: const Text('Finalizar Mis Entregas'),
        icon: const Icon(Icons.exit_to_app),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_groupedDeliveries == null || _groupedDeliveries!.isEmpty) {
      return const EmptyDeliveriesWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveries,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groupedDeliveries!.length,
        itemBuilder: (context, index) {
          return DeliveryCard(
            delivery: _groupedDeliveries![index],
            onMarkAsDelivered: _markAsDelivered,
          );
        },
      ),
    );
  }
}
