// ignore: file_names
import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/domain/delivery-driver/delivery-driver_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DeliveryDriverService implements DeliveryDriverRepository {
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}entregas';
  final LocalStorageService _localStorageService = LocalStorageService();
  List<DeliveryDriver>? _temp;

  @override
  Future<List<DeliveryDriver>> obtainDelivery(int? codEmpleado) async {
    if (codEmpleado == null) {
      throw Exception('Employee code cannot be null');
    }

    final token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/chofer-entrega/',
        data: {
          'uchofer': codEmpleado,
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
        _temp = data.map((item) => DeliveryDriver.fromJson(item)).toList();
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

  // Nuevo método para guardar los datos de la entrega
  @override
  Future<void> saveDeliveryData(
      {required int docEntry,
      required String db,
      required double latitude,
      required double longitude,
      required String address,
      required String dateTime,
      required String obs,
      required int audUsuario}) async {
    final token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/registro-entrega-chofer',
        data: {
          'docEntry': docEntry,
          'db': db,
          'latitud': latitude,
          'longitud': longitude,
          'direccionEntrega': address,
          'fechaEntrega': dateTime,
          'obs': obs,
          'audUsuario': audUsuario
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201) {
        // Éxito, datos guardados
        debugPrint('Datos de la entrega guardados correctamente.');
      } else {
        // Manejar errores del servidor
        throw Exception(
            'El servidor respondió con código de estado: ${response.statusCode}. Mensaje: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.toString()}');
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> registerStartDelivery(DeliveryDriver mb) async {
    final token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/registro-inicio-fin-entrega',
        data: mb,
        options: Options(
          contentType: 'application/json',
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201) {
        // Éxito, datos guardados
        debugPrint('Datos de la entrega de inicio guardados correctamente.');
      } else {
        // Manejar errores del servidor
        throw Exception(
            'El servidor respondió con código de estado: ${response.statusCode}. Mensaje: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.toString()}');
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> registerFinishDelivery(DeliveryDriver mb) async {
    final token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/registro-inicio-fin-entrega',
        data: mb,
        options: Options(
          contentType: 'application/json',
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201) {
        // Éxito, datos guardados
        debugPrint(
            'Datos de la finalizacion de entregas guardados correctamente.');
      } else {
        // Manejar errores del servidor
        throw Exception(
            'El servidor respondió con código de estado: ${response.statusCode}. Mensaje: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.toString()}');
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }



  /// Obtiene la lista de choferes
  @override
  Future<List<DeliveryDriver>> obtainDriver() async {
    
    final token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/choferes/',
        data: { },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        _temp = data.map((item) => DeliveryDriver.fromJson(item)).toList();
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
  Future<List<DeliveryDriver>> obtainDeliveriesXEmp(int codEmpleado, String fecha) async {

    final token = await _localStorageService.getToken();

    try {
      final response = await _dio.post(
        '$_baseUrl/entregas-fecha/',
        data: {
          'fechaEntrega': fecha,
          'codEmpleado': codEmpleado
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
        _temp = data.map((item) => DeliveryDriver.fromJson(item)).toList();
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


}
