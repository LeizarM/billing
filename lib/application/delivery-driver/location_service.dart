// lib/application/location/location_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final Dio _dio;

  LocationService({Dio? dio}) : _dio = dio ?? Dio();

  Future<bool> checkAndRequestLocationPermissions(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El servicio de ubicación está deshabilitado.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Los permisos de ubicación están denegados.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Los permisos de ubicación están denegados permanentemente.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      print('Error al obtener la posición: $e');
      return null;
    }
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        final address = data['display_name'] as String?;
        return address ?? 'Dirección no disponible';
      } else {
        print('Error al obtener la dirección: ${response.statusCode}');
        return 'Dirección no disponible';
      }
    } catch (e) {
      print('Error al obtener la dirección: $e');
      return 'Dirección no disponible';
    }
  }
}
