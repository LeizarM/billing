import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/application/delivery-driver/location_service.dart';
import 'package:billing/presentation/delivery-driver/delivery-driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    // Ya no necesitamos verificar entregas activas aquí
  }

  Future<void> _startDeliveries() async {
    setState(() => _isLoading = true);
    try {
      var userData = await _localStorageService.getUser();
      if (userData == null) {
        throw Exception('User data not found');
      }

      var position = await _locationService.getCurrentPosition();
      String address = await _locationService.getAddressFromLatLng(
          position!.latitude, position!.longitude);
      String currentDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('deliveriesActive', true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DeliveryDriverScreen()),
      );
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
