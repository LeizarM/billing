import 'package:dio/dio.dart';

import '../../infrastructure/persistence/database_helper.dart';

class SyncService {
  final Dio _dio = Dio();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final String _baseUrl = 'http://200.105.169.35:7000/paginaXApp';
  //'http://192.168.3.107:9223/paginaXApp';
  Future<void> syncProductos(String token, int codCiudad) async {
    try {
      print('Iniciando sincronización de productos');
      final response = await _dio.post(
        '$_baseUrl/articulosX',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'codCiudad': codCiudad},
      );

      print('Respuesta recibida: ${response.statusCode}');
      print('Tipo de datos recibidos: ${response.data.runtimeType}');
      print('Contenido de la respuesta: ${response.data}');

      if (response.data is List) {
        List<Map<String, dynamic>> productos =
            List<Map<String, dynamic>>.from(response.data);
        print('Número de productos recibidos: ${productos.length}');
        await _databaseHelper.upsertProductos(productos);
        print('Sincronización completada con éxito');
      } else if (response.data is Map<String, dynamic>) {
        // Si la respuesta es un mapa, verifica si contiene una lista de productos
        if (response.data.containsKey('productos') &&
            response.data['productos'] is List) {
          List<Map<String, dynamic>> productos =
              List<Map<String, dynamic>>.from(response.data['productos']);
          print('Número de productos recibidos: ${productos.length}');
          await _databaseHelper.upsertProductos(productos);
          print('Sincronización completada con éxito');
        } else {
          throw Exception(
              'La respuesta no contiene una lista de productos válida');
        }
      } else {
        throw Exception(
            'Formato de respuesta inesperado: ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Response headers: ${e.response?.headers}');
      print('Request data: ${e.requestOptions.data}');
      throw Exception('Error en la solicitud HTTP: ${e.message}');
    } catch (e) {
      print('Error inesperado: $e');
      throw Exception('Error sincronizando productos: $e');
    }
  }
}
