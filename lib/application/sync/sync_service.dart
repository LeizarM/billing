import 'package:billing/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/persistence/database_helper.dart';

class SyncService {
  final Dio _dio = Dio();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final String _baseUrl = '${BASE_URL}paginaXApp';

  Future<void> syncProductos(String token, int codCiudad) async {
    try {
      debugPrint('Iniciando sincronización de productos');
      final response = await _dio.post(
        '$_baseUrl/articulosX',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'codCiudad': codCiudad},
      );

      debugPrint('Respuesta recibida: ${response.statusCode}');
      debugPrint('Tipo de datos recibidos: ${response.data.runtimeType}');
      debugPrint('Contenido de la respuesta: ${response.data}');

      if (response.data is List) {
        List<Map<String, dynamic>> productos =
            List<Map<String, dynamic>>.from(response.data);
        debugPrint('Número de productos recibidos: ${productos.length}');
        await _databaseHelper.upsertProductos(productos);
        debugPrint('Sincronización completada con éxito');
      } else if (response.data is Map<String, dynamic>) {
        // Si la respuesta es un mapa, verifica si contiene una lista de productos
        if (response.data.containsKey('productos') &&
            response.data['productos'] is List) {
          List<Map<String, dynamic>> productos =
              List<Map<String, dynamic>>.from(response.data['productos']);
          debugPrint('Número de productos recibidos: ${productos.length}');
          await _databaseHelper.upsertProductos(productos);
          debugPrint('Sincronización completada con éxito');
        } else {
          throw Exception(
              'La respuesta no contiene una lista de productos válida');
        }
      } else {
        throw Exception(
            'Formato de respuesta inesperado: ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.type} - ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      debugPrint('Response headers: ${e.response?.headers}');
      debugPrint('Request data: ${e.requestOptions.data}');
      throw Exception('Error en la solicitud HTTP: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado: $e');
      throw Exception('Error sincronizando productos: $e');
    }
  }
}
