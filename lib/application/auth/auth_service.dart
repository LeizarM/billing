import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/login.dart';
import '../../infrastructure/persistence/database_helper.dart';

class AuthService implements AuthRepository {
  late Dio _dio;
  final String _baseUrl = '${BASE_URL}auth';
  final LocalStorageService _localStorageService = LocalStorageService();
  
  AuthService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => true, // Acepta cualquier código de estado
    ));
    
    // Configuración específica para SSL
    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
    
    // Logger para ver exactamente qué está pasando
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));
  }
  
  @override
  Future<Login> login(String username, String password) async {
    try {
     
      
      final response = await _dio.post(
        '$_baseUrl/login/',
        data: {'login': username, 'password2': password},
        options: Options(
          contentType: 'application/json',
          headers: {'Accept': 'application/json'},
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final login = Login.fromJson(response.data);
        await _localStorageService.saveUser(login);
        return login;
      } else {
        throw Exception('Failed to login: Status ${response.statusCode}, Data: ${response.data}');
      }
    } on DioException catch (e) {
      print('DioException during login: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response}');
      print('DioException error: ${e.error}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Unable to receive data from the server. The server might be overloaded.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection error: ${e.message}. Please verify the server address and your network settings.');
      } else if (e.response != null) {
        // Manejar errores HTTP específicos
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        throw Exception('Server returned error $statusCode: ${responseData ?? e.message}');
      } else {
        throw Exception('An error occurred: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error during login: $e');
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
      final response = await _dio.post(
        '$_baseUrl/changePasswordDefault',
        data: {
          'npassword': nPassword,
          'codUsuario': codUsuario,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to change password: Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to change password: ${e.message}');
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
  
  @override
  Future<void> logout() async {
    await _localStorageService.clearUser();
    // Resetear el estado de sincronización
    DatabaseHelper.instance.resetSyncState();
    // Limpiar cualquier caché o estado adicional si es necesario
  }
  
  // Método para verificar la conectividad del servidor
  Future<bool> checkServerConnectivity() async {
    try {
      final response = await _dio.get('$_baseUrl/login/',
          options: Options(
            method: 'HEAD',
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ));
      return response.statusCode! < 400;
    } catch (e) {
      print('Server connectivity check failed: $e');
      return false;
    }
  }
}