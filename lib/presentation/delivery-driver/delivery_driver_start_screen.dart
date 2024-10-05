// delivery_driver_start_screen.dart
import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/application/delivery-driver/location_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/presentation/delivery-driver/delivery-driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryDriverStartScreen extends StatefulWidget {
  const DeliveryDriverStartScreen({Key? key}) : super(key: key);

  @override
  _DeliveryDriverStartScreenState createState() =>
      _DeliveryDriverStartScreenState();
}

class _DeliveryDriverStartScreenState extends State<DeliveryDriverStartScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DeliveryDriverService _deliveryDriverService = DeliveryDriverService();
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  Login? userData;

  @override
  void initState() {
    super.initState();
    _checkDeliveriesStatus();
  }

  bool isTokenExpired(String token) {
    bool hasExpired = JwtDecoder.isExpired(token);
    return hasExpired;
  }

  // Verifica el estado de las entregas al iniciar la pantalla
  Future<void> _checkDeliveriesStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool deliveriesActive = prefs.getBool('deliveriesActive') ?? false;
    if (deliveriesActive) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DeliveryDriverScreen()),
      );
    }
  }

  Future<void> _startDeliveries() async {
    setState(() => _isLoading = true);
    try {
      var userData = await _localStorageService.getUser();
      if (userData == null) {
        throw Exception('User data not found');
      }

      // Solicita permisos de ubicación
      bool hasPermission =
          await _locationService.checkAndRequestLocationPermissions(context);
      if (!hasPermission) {
        throw Exception('Permisos de ubicación no concedidos');
      }

      // Obtiene la posición actual
      var position = await _locationService.getCurrentPosition();
      if (position == null) {
        throw Exception('No se pudo obtener la posición.');
      }

      // Obtiene la dirección a partir de la posición usando Dio
      String address = await _locationService.getAddressFromLatLng(
          position.latitude, position.longitude);

      // Imprime los datos en la consola
      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');
      print('Address: $address');

      String currentDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('deliveriesActive', true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DeliveryDriverScreen()),
      );

      userData = await _localStorageService.getUser();

      DeliveryDriver temp = DeliveryDriver();

      debugPrint(currentDateTime);

      temp.docEntry = -1;
      temp.docNum = 0;
      temp.factura = 0;
      temp.cardName = "Inicio de Entrega";
      temp.codEmpleado = userData?.codEmpleado;
      temp.valido = 'V';
      temp.db = 'ALL';
      temp.direccionEntrega = address;
      temp.fueEntregado = 1;
      temp.fechaEntrega = currentDateTime;
      temp.latitud = position.latitude;
      temp.longitud = position.longitude;
      temp.obs = "Iniciando Entregas";
      temp.audUsuario = userData?.codUsuario;

      await _deliveryDriverService.registerStartDelivery(temp);
    } catch (e) {
      print('Error al iniciar las entregas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar las entregas: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Entregas',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _startDeliveries,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Iniciar Entregas',
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }
}
