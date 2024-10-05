import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:billing/domain/view-menu/view-menu.dart';
import 'package:billing/domain/view-menu/view-menu_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ViewMenuService implements VistaRepository {
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}view';

  final LocalStorageService _localStorageService = LocalStorageService();
  List<Vista>? _temp;

  @override
  Future<List<Vista>> obtainViewMenu(int codUsuario) async {
    final token = await _localStorageService.getToken();
    try {
      final response = await _dio.post(
        '$_baseUrl/vistaDinamica',
        data: {
          'codUsuario': codUsuario,
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
        _temp = data.map((item) => Vista.fromJson(item)).toList();
        return _temp ?? [];
      } else if (response.statusCode == 404) {
        debugPrint(
            'Error 404: Recurso no encontrado. URL: ${response.requestOptions.uri}');
        debugPrint('Datos enviados: ${response.requestOptions.data}');
        throw Exception(
            'El recurso solicitado no fue encontrado en el servidor.');
      } else {
        debugPrint(
            'Error inesperado. Código de estado: ${response.statusCode}');
        debugPrint('Respuesta del servidor: ${response.data}');
        throw Exception(
            'Error en la solicitud al servidor. Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('URL de la solicitud: ${e.requestOptions.uri}');
      debugPrint('Datos enviados: ${e.requestOptions.data}');
      if (e.response != null) {
        debugPrint('Respuesta del servidor: ${e.response?.data}');
      }
      throw Exception('Error en la conexión con el servidor: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado: $e');
      throw Exception('Error inesperado al obtener artículos: $e');
    }
  }
}
