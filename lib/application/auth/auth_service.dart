import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:dio/dio.dart';

import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/login.dart';
import '../../infrastructure/persistence/database_helper.dart';

class AuthService implements AuthRepository {
  final Dio _dio = Dio();

  //final String _baseUrl = 'http://200.105.169.35:7000/auth';
  final String _baseUrl = '${BASE_URL}auth';
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  Future<Login> login(String username, String password) async {
    try {
      _dio.options.headers['Content-Type'] = 'application/json';
      final response = await _dio.post(
        '$_baseUrl/login/',
        data: {'login': username, 'password2': password},
      );
      if (response.data is Map<String, dynamic>) {
        final login = Login.fromJson(response.data);
        await _localStorageService.saveUser(login);

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
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> isDefaultPassword(String password) async {
    return password == '123456789';
  }

  Future<void> changePassword(String nPassword) async {
    final token = await _localStorageService.getToken();
    final codUsuario = await _localStorageService.getCodUsuario();
    try {
      await _dio.post(
        '$_baseUrl/changePasswordDefault',
        data: {
          'npassword': nPassword,
          'codUsuario': codUsuario,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _localStorageService.clearUser();

    // Resetear el estado de sincronización
    DatabaseHelper.instance.resetSyncState();

    // Aquí podrías agregar cualquier otra limpieza necesaria
  }
}
