import 'package:billing/application/auth/local_storage_service.dart';
import 'package:dio/dio.dart';

import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/login.dart';
import '../sync/sync_service.dart';

class AuthService implements AuthRepository {
  final Dio _dio = Dio();
  Login? _userData;

  final String _baseUrl =
      'http://192.168.3.107:9223/auth'; // Reemplaza con la URL de tu API

  final SyncService _syncService = SyncService();

  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  Future<Login> login(String username, String password) async {
    try {
      print('$_baseUrl/login/');

      _dio.options.headers['Content-Type'] = 'application/json';
      final response = await _dio.post(
        '$_baseUrl/login/',
        data: {'login': username, 'password2': password},
      );

      if (response.data is Map<String, dynamic>) {
        final login = Login.fromJson(response.data);

        // Guardar usuario en el almacenamiento local
        await _localStorageService.saveUser(login);

        _userData = await _localStorageService.getUser();

        // Iniciar sincronización después del login exitoso
        await _syncService.syncProductos(login.token, _userData!.codCiudad);

        return login;
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Unable to receive data from the server');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection error: ${e.message}');
      } else {
        throw Exception('An error occurred: ${e.message}');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    //
  }
}
