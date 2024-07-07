import 'package:dio/dio.dart';

import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/login.dart';
import '../sync/sync_service.dart';

class AuthService implements AuthRepository {
  final Dio _dio = Dio();
  final String _baseUrl =
      'https://tu-api.com'; // Reemplaza con la URL de tu API
  final SyncService _syncService = SyncService();

  @override
  Future<Login> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {'login': username, 'password2': password},
      );

      if (response.statusCode == 200) {
        final login = Login.fromJson(response.data);

        // Iniciar sincronización después del login exitoso
        await _syncService.syncProductos(login.token);

        return login;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  @override
  Future<void> logout() async {
    //
  }
}
