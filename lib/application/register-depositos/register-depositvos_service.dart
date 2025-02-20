// lib/infrastructure/repositories/deposito_repository_impl.dart
import 'dart:convert';
import 'dart:io';

import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:billing/domain/register-depositos/ChBanco.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'package:billing/domain/register-depositos/register-depositos_repository.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class DepositoRepositoryImpl implements DepositoRepository {
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}deposito-cheque';
  final LocalStorageService _localStorageService = LocalStorageService();

  DepositoRepositoryImpl() {
    _dio.options.validateStatus = (status) {
      return status! < 500; // Acepta todos los códigos menores a 500 para manejarlos manualmente
    };
  }

  @override
  Future<bool> registrarDeposito(DepositoCheque deposito, File imagen) async {
    final token = await _localStorageService.getToken();

    print(deposito.toJson());

    try {
      FormData formData = FormData.fromMap({
        'depositoCheque': jsonEncode(deposito.toJson()),
        'file': await MultipartFile.fromFile(
          imagen.path,
          contentType: MediaType('image', 'jpg'),
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/registro',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Manejar específicamente el código 409
      if (response.statusCode == 409) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Error de validación en el servidor'
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Error al registrar depósito');
      }

    } on DioException catch (e) {
      if (e.response != null) {
        // Obtener el mensaje de error del servidor si está disponible
        final errorMessage = e.response?.data['message'] ?? 
            'Error al procesar la solicitud en el servidor';
        throw Exception(errorMessage);
      } else {
        // Error de red u otro tipo de error
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<ChBanco>> getBancos() async {
   final token = await _localStorageService.getToken();
   try {
      final response = await _dio.post('$_baseUrl/lst-banco', options: Options(
          headers: {'Authorization': 'Bearer $token' },
        ));
      final data = response.data['data'] as List;
      return data.map((json) => ChBanco.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener bancos: $e');
    }
  }

  @override
  Future<List<Empresa>> getEmpresas() async {
    final token = await _localStorageService.getToken();
    try {
      final response = await _dio.post('$_baseUrl/lst-empresas', options: Options(
          headers: {'Authorization': 'Bearer $token' }));
      final data = response.data['data'] as List;
      return data.map((json) => Empresa.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener empresas: $e');
    }
  }

  @override
  Future<List<SocioNegocio>> getSociosNegocio(int codEmpresa) async {
    final token = await _localStorageService.getToken();
    try {
      final response = await _dio.post(
        '$_baseUrl/lst-socios-negocio',
        data: {'codEmpresa': codEmpresa},
        options: Options(
          headers: {'Authorization': 'Bearer $token' },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => SocioNegocio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener socios de negocio: $e');
    }
  }

  // Implementa los otros métodos...
}