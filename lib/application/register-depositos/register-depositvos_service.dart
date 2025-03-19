import 'dart:convert';
import 'dart:io';
import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/constants/constants.dart';
import 'package:billing/domain/register-depositos/BancoXCuenta.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/NotaRemision.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'package:billing/domain/register-depositos/register-depositos_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class DepositoRepositoryImpl implements DepositoRepository {
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}deposito-cheque';
  final LocalStorageService _localStorageService = LocalStorageService();

  DepositoRepositoryImpl() {
    _dio.options.validateStatus = (status) => status! < 500;
  }

  @override
  Future<bool> registrarDeposito(
      DepositoCheque deposito, dynamic imagen) async {
    final token = await _localStorageService.getToken();
    try {
      MultipartFile multipartFile;

      if (imagen is Uint8List) {
        multipartFile = MultipartFile.fromBytes(
          imagen,
          filename: "imagen.jpg",
          contentType: MediaType('image', 'jpeg'),
        );
      } else if (imagen is File) {
        multipartFile = await MultipartFile.fromFile(
          imagen.path,
          filename: "imagen.jpg",
          contentType: MediaType('image', 'jpeg'),
        );
      } else {
        throw Exception('Formato de imagen no soportado');
      }

      FormData formData = FormData.fromMap({
        'depositoCheque': jsonEncode(deposito.toJson()),
        'file': multipartFile,
      });

      final response = await _dio.post(
        '$_baseUrl/registro',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 409) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error:
              response.data['message'] ?? 'Error de validación en el servidor',
        );
      }

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error en registrarDeposito: $e');
      rethrow;
    }
  }

  @override
  Future<List<BancoXCuenta>> getBancos(int codEmpresa) async {
    final token = await _localStorageService.getToken();

    try {
      final response = await _dio.post('$_baseUrl/lst-banco',
          data: {
            'codEmpresa': codEmpresa,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
      final data = response.data['data'] as List;
      return data.map((json) => BancoXCuenta.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener bancos: $e');
    }
  }

  @override
  Future<List<Empresa>> getEmpresas() async {
    final token = await _localStorageService.getToken();
    try {
      final response = await _dio.post('$_baseUrl/lst-empresas',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
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
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => SocioNegocio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener socios de negocio: $e');
    }
  }

  @override
  Future<List<NotaRemision>> getNotasRemision( int codEmpresa, String codCliente ) async {
    final token = await _localStorageService.getToken();
    try {
      final response = await _dio.post(
        '$_baseUrl/lst-notaRemision',
        data: {'codEmpresaBosque': codEmpresa, 'codCliente': codCliente},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => NotaRemision.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener socios de negocio: $e');
    }
  }
  
  @override
  Future<bool> guardarNotaRemision(NotaRemision notaRemision) async {
    
    final token = await _localStorageService.getToken();

    try {
      // Convert NotaRemision to a JSON map first
      final jsonData = notaRemision.toJson();
      
      debugPrint('jsonData: $jsonData');

      final response = await _dio.post(
        '$_baseUrl/registrar-nota-remision',
        data: jsonData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error en guardarNotaRemision: $e');
      rethrow;
    }
  }
}
