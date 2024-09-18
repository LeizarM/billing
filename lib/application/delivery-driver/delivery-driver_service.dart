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
    debugPrint('Token: $token');
    debugPrint('Base URL: $_baseUrl');
    debugPrint('Employee Code: $codEmpleado');

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
}
