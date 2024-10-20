import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/application/delivery-driver/location_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:billing/presentation/auth/login_screen.dart';
import 'package:billing/presentation/dashboard/dashboard_screen.dart';
import 'package:billing/presentation/delivery-driver/utils/dialogs.dart';
import 'package:billing/presentation/delivery-driver/widgets/customLoadingIndicator.dart';
import 'package:billing/presentation/delivery-driver/widgets/delivery_card.dart';
import 'package:billing/presentation/delivery-driver/widgets/empty_deliveries_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Importa compute
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

// Initialize logger
final logger = Logger();

// Define una función de nivel superior para agrupar entregas
List<GroupedDelivery> groupDeliveries(List<DeliveryDriver> deliveries) {
  final grouped = groupBy(deliveries, (DeliveryDriver d) => d.docEntry);
  return grouped.entries.map((entry) {
    final items = entry.value;
    return GroupedDelivery(
      docEntry: entry.key ?? 0,
      cardName: items.first.cardName ?? 'Sin Nombre',
      docDate: items.first.docDate != null
          ? DateTime.parse(items.first.docDate.toString())
          : DateTime.now(),
      addressEntregaMat:
          items.first.addressEntregaMat ?? 'Dirección no disponible',
      items: items,
      db: items.first.db ?? 'DB Desconocida',
      obs: items.first.obs ?? '',
    );
  }).toList();
}

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
    if (!mounted) {
      return;
    }

    _safeSetState(() => _isLoading = true);
    try {
      final token = await _localStorageService.getToken();

      if (token == null) {
        _handleExpiredToken();
        return;
      }

      bool expired = isTokenExpired(token);
      logger.d(expired.toString());
      if (expired) {
        await _handleExpiredToken();
        return;
      }

      userData = await _localStorageService.getUser();

      if (userData != null) {
        final deliveries =
            await _deliveryDriverService.obtainDelivery(userData!.codEmpleado);

        if (mounted) {
          // Usa compute para agrupar las entregas en un isolate separado
          final grouped = await compute(groupDeliveries, deliveries);
          _safeSetState(() {
            _groupedDeliveries = grouped;
          });
        }
      } else {
        logger.w('User data or employee code is null');
        if (mounted) {
          _showErrorSnackBar('Datos del usuario no disponibles.');
        }
      }
    } catch (e) {
      logger.e('Error loading deliveries: $e');
      if (mounted) {
        _showErrorSnackBar('Error al cargar las entregas: $e');
      }
    } finally {
      _safeSetState(() => _isLoading = false);
    }
  }

  Future<void> _handleExpiredToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('deliveriesActive', false);
    if (mounted) {
      logger.i("Redireccionando a Login ....");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  bool isTokenExpired(String token) {
    bool hasExpired = JwtDecoder.isExpired(token);
    return hasExpired;
  }

  void _handleObservationChange(int docEntry, String newObservation) {
    setState(() {
      final delivery = _groupedDeliveries
          ?.firstWhereOrNull((delivery) => delivery.docEntry == docEntry);
      if (delivery != null) {
        delivery.obs = newObservation;
      }
    });
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

      if (userData == null) {
        throw Exception('Datos del usuario no disponibles.');
      }

      await _saveDeliveryData(
        docEntry: delivery.docEntry,
        db: delivery.db,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        dateTime: currentDateTime,
        audUsuario: userData!.codUsuario,
        observation: delivery.obs,
      );

      setState(() => delivery.isDelivered = true);
      await _loadDeliveries();
      _showSuccessSnackBar('Entrega marcada como completada');
    } catch (e) {
      logger.e('Error al marcar como entregada: $e');
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
    required String observation,
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
        obs: observation,
      );
      logger.i('Datos de la entrega guardados correctamente.');
    } catch (e) {
      logger.e('Error al guardar los datos de la entrega: $e');
      _showErrorSnackBar('Error al guardar los datos de la entrega');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
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
        duration: const Duration(seconds: 3),
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
        bool hasPermission =
            await _locationService.checkAndRequestLocationPermissions(context);
        if (!hasPermission) {
          throw Exception('Permisos de ubicación no concedidos');
        }

        Position? position = await _locationService.getCurrentPosition();
        if (position == null) {
          throw Exception('No se pudo obtener la posición.');
        }

        String address = await _locationService.getAddressFromLatLng(
            position.latitude, position.longitude);

        logger.i('Finalizando Entregas');
        logger.i('Latitude: ${position.latitude}');
        logger.i('Longitude: ${position.longitude}');
        logger.i('Address: $address');

        String currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('deliveriesActive', false);

        DeliveryDriver temp = DeliveryDriver();

        temp.docEntry = 0;
        temp.docNum = 0;
        temp.factura = 0;
        temp.cardCode = " ";
        temp.addressEntregaFac = "";
        temp.addressEntregaMat = "";
        temp.cardName = "Fin Entregas";
        temp.codEmpleado = userData?.codEmpleado;
        temp.valido = 'V';
        temp.db = 'ALL';
        temp.direccionEntrega = address;
        temp.fueEntregado = 1;
        temp.fechaEntrega = currentDateTime;
        temp.latitud = position.latitude;
        temp.longitud = position.longitude;
        temp.obs = "Finalizando Entregas";
        temp.audUsuario = userData?.codUsuario;

        await _deliveryDriverService.registerFinishDelivery(temp);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const DashboardScreen(
                    initialIndex: 0,
                  )),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        logger.e('Error al finalizar las entregas: $e');
        _showErrorSnackBar('Error al finalizar las entregas: $e');
      } finally {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Entregas Pendientes',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 2,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDeliveries,
          tooltip: 'Actualizar',
        ),
      ],
      // Puedes agregar un fondo de gradiente si lo deseas
      // flexibleSpace: Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [Colors.teal, Colors.tealAccent],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      );
    }

    if (_groupedDeliveries == null || _groupedDeliveries!.isEmpty) {
      return const EmptyDeliveriesWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveries,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _groupedDeliveries!.length,
        itemBuilder: (context, index) {
          final delivery = _groupedDeliveries![index];
          return AnimatedOpacity(
            opacity: delivery.isDelivered ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: DeliveryCard(
              delivery: delivery,
              onMarkAsDelivered: _markAsDelivered,
              onObservationChanged: (newObservation) {
                _handleObservationChange(delivery.docEntry, newObservation);
              },
            ),
          );
        },
      ),
    );
  }
}
