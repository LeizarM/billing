import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:billing/domain/fuel-control/FuelControl.dart';
import 'package:billing/domain/fuel-control/fuelControl_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FuelControlService implements FuelControlRepository {
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}gasolina';
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  Future<List<CombustibleControl>> getCars() async {
    String? token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/lst-coches/',
        data: {},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Extract the data array directly from the known response format
        if (responseData.containsKey('data')) {
          final carsList = responseData['data'] as List<dynamic>;
          return carsList.map((item) => CombustibleControl.fromJson(item)).toList();
        } else {
          throw Exception('API response missing expected "data" field');
        }
      } else {
        throw Exception(
            'Server responded with status code: ${response.statusCode}. Message: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      debugPrint('Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting cars: $e');
      throw Exception('Error getting cars: $e');
    }
  }

 Future<void> registerFuelControl(CombustibleControl fuelControl) async {
  String? token = await _localStorageService.getToken();
  try {
    // Imprimir el objeto que estás enviando para depuración
    debugPrint('Datos a enviar: ${fuelControl.toJson()}');
    
    final response = await _dio.post(
      '$_baseUrl/registrar-gasolina',
      data: fuelControl.toJson(),
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        // Importante: cambia esto para que no lance excepción con 500
        validateStatus: (status) => true,
      ),
    );
    
    // Imprime la respuesta completa para ver qué está devolviendo el servidor
    debugPrint('Respuesta del servidor: ${response.data}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      debugPrint('Operación exitosa');
    } else {
      throw Exception('Error: ${response.statusCode}, mensaje: ${response.data}');
    }
  } on DioException catch (e) {
    debugPrint('Error de red detallado: ${e.toString()}');
    debugPrint('Respuesta del error: ${e.response?.data}');
    throw Exception('Error de red: ${e.message}');
  } catch (e) {
    debugPrint('Error al registrar control de combustible: $e');
    throw Exception('Error al registrar control de combustible: $e');
  }
}
}