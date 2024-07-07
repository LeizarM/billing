import 'package:dio/dio.dart';

import '../../infrastructure/persistence/database_helper.dart';

class SyncService {
  final Dio _dio = Dio();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final String _baseUrl =
      'https://tu-api.com'; // Reemplaza con la URL de tu API

  Future<void> syncProductos(String token) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/productos',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> productos =
            List<Map<String, dynamic>>.from(response.data);
        await _databaseHelper.upsertProductos(productos);
      } else {
        throw Exception('Failed to fetch productos');
      }
    } catch (e) {
      throw Exception('Error syncing productos: $e');
    }
  }
}
