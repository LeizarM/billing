

import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';
import 'package:billing/domain/driver-car/solicitud-chofer_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DriverCarService implements SolicitudChoferRepository {
  
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}prestamo-coches';
  final LocalStorageService _localStorageService = LocalStorageService();


  @override
Future<void> registerSolicitudChofer(SolicitudChofer solicitud) async {
  String? token = await _localStorageService.getToken();

  debugPrint('Token: $token');
  debugPrint('Datos de la solicitud: ${solicitud.toJson()}'); // Usar toJson() para logging

  try {
    final response = await _dio.post(
      '$_baseUrl/registroSolicitud',
      data: solicitud.toJson(), // Enviar directamente el Map generado por toJson()
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Especificar el tipo de contenido
        },
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 201) {
      debugPrint('Solicitud de chofer registrada correctamente.');
    } else {
      throw Exception(
        'El servidor respondió con código de estado: ${response.statusCode}. Mensaje: ${response.data}',
      );
    }
  } on DioException catch (e) {
    debugPrint('DioException: ${e.toString()}');
    if (e.response != null) {
      debugPrint('Response data: ${e.response?.data}');
      debugPrint('Response headers: ${e.response?.headers}');
    }
    throw Exception('Error de red: ${e.message}');
  } catch (e) {
    debugPrint('Error inesperado: $e');
    throw Exception('Error inesperado: $e');
  }
}
  
  
  @override
  Future<void> obtainSolicitudes(int codEmpleado) {
    // TODO: implement obtainSolicitudes
    throw UnimplementedError();
  }

  
  
}