import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:billing/domain/driver-car/EstadoChofer.dart';
import 'package:billing/domain/driver-car/PrestamoChofer.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';
import 'package:billing/domain/driver-car/solicitud-chofer_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DriverCarService implements SolicitudChoferRepository {
  
  
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}prestamo-coches';
  final LocalStorageService _localStorageService = LocalStorageService();

  List<SolicitudChofer>? _temp;
  List<EstadoChofer>? _tempEst ;

  @override
  Future<void> registerSolicitudChofer(SolicitudChofer solicitud) async {
    
    String? token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/registroSolicitud',
        data: solicitud
            .toJson(), // Enviar directamente el Map generado por toJson()
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':
                'application/json', // Especificar el tipo de contenido
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
  Future<List<SolicitudChofer>> obtainSolicitudes(int codEmpleado) async {
    
    String? token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/solicitudes/',
        data: {
          'codEmpSoli': codEmpleado,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        _temp = data.map((item) => SolicitudChofer.fromJson(item)).toList();
        return _temp ?? [];
      } else {
        throw Exception(
            'Server responded with status code: ${response.statusCode}. Message: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.toString()}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('DioException message: ${e.message}');
      debugPrint('DioException response: ${e.response}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<EstadoChofer>> lstEstados() async {
    
      String? token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/estados/',
        data: {
          
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        _tempEst = data.map((item) => EstadoChofer.fromJson(item)).toList();
        return _tempEst ?? [];
      } else {
        throw Exception(
            'Server responded with status code: ${response.statusCode}. Message: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.toString()}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('DioException message: ${e.message}');
      debugPrint('DioException response: ${e.response}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }

  }

  @override
  Future<void> registerPrestamo(PrestamoChofer mb) async {


    String? token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/registroPrestamo',
        data: mb
            .toJson(), // Enviar directamente el Map generado por toJson()
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':
                'application/json', // Especificar el tipo de contenido
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



  
}
