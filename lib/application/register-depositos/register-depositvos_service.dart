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
import 'package:intl/intl.dart';

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
      
      // Check if response has data and it's a list
      if (response.data != null && 
          response.data['data'] != null && 
          response.data['data'] is List) {
        final data = response.data['data'] as List;
        return data.map((json) => NotaRemision.fromJson(json)).toList();
      }
      
      // Return empty list if there's no data
      return [];
    } catch (e) {
      // Log the error but return empty list instead of throwing
      print('Error al obtener notas de remisión: $e');
      return [];
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
  
  @override
  Future<List<DepositoCheque>> obtenerDepositos(int codEmpresa, int idBxC, DateTime fechaInicio, DateTime fechaFin, String codCliente, String estadoFiltro) async {
    final token = await _localStorageService.getToken();
    
    // Formatear fechas en el formato que espera el API
    final fechaInicioStr = DateFormat('yyyy-MM-dd').format(fechaInicio);
    final fechaFinStr = DateFormat('yyyy-MM-dd').format(fechaFin);
    
    // Crear el objeto de datos para el request
    final Map<String, dynamic> requestData = {
      'codEmpresa': codEmpresa,
      'idBxC': idBxC,
      'fechaInicio': fechaInicioStr,
      'fechaFin': fechaFinStr,
      'codCliente': codCliente,
      'estadoFiltro': estadoFiltro,
    };
    
    // Imprimir los datos del request para depuración
    debugPrint('Request data: $requestData');
    
    try {
      final response = await _dio.post(
        '$_baseUrl/listar',
        data: requestData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      debugPrint('Response status: ${response.statusCode}');
      
      // Robust handling for different response formats
      if (response.data != null) {
        try {
          // Print response structure for debugging
          debugPrint('Response type: ${response.data.runtimeType}');
          
          List<dynamic> dataList;
          
          if (response.data is Map) {
            // Handle case where response.data is a Map with 'data' key
            if (response.data.containsKey('data')) {
              dataList = response.data['data'] as List<dynamic>;
            } else {
              debugPrint('Response data does not contain "data" key: ${response.data.keys}');
              return [];
            }
          } else if (response.data is List) {
            // Handle case where response.data is directly a List
            dataList = response.data as List<dynamic>;
          } else {
            debugPrint('Unexpected response format: ${response.data}');
            return [];
          }
          
          return dataList.map((json) => DepositoCheque.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error parsing response data: $e');
          return [];
        }
      }
      
      // Return empty list if there's no data
      return [];
    } catch (e) {
      // Log the error but return empty list instead of throwing
      debugPrint('Error al obtener depósitos: $e');
      return [];
    }
  }
  
  @override
  Future<List<DepositoCheque>> lstDepositxIdentificar(int idBxC, DateTime fechaInicio, DateTime fechaFin, String codCliente) async {
    final token = await _localStorageService.getToken();
    
    // Formatear fechas en el formato que espera el API
    final fechaInicioStr = DateFormat('yyyy-MM-dd').format(fechaInicio);
    final fechaFinStr = DateFormat('yyyy-MM-dd').format(fechaFin);
    
    // Asegurar que idBxC sea 0 si es necesario y codCliente sea una cadena vacía si es nulo
    final int safeIdBxC = 0; // Siempre enviar 0 como mencionado
    final String safeCodeClient = codCliente.isEmpty ? " " : codCliente;
    
    // Crear el objeto de datos para el request
    final Map<String, dynamic> requestData = {
      'idBxC': safeIdBxC,
      'fechaInicio': fechaInicioStr,
      'fechaFin': fechaFinStr,
      'codCliente': safeCodeClient,
    };
    
    debugPrint('Request data for lstDepositxIdentificar: $requestData');
    
    try {
      final response = await _dio.post(
        '$_baseUrl/listar-dep-identificar', // Ajuste el endpoint si es necesario
        data: requestData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      debugPrint('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        // La respuesta tiene la estructura {"message": "...", "data": [...], "status": 200}
        if (response.data is Map && response.data.containsKey('data')) {
          final data = response.data['data'] as List<dynamic>;
          return data.map((json) => DepositoCheque.fromJson(json)).toList();
        }
      }
      
      // Return empty list if there's no data or incorrect format
      return [];
    } catch (e) {
      debugPrint('Error en lstDepositxIdentificar: $e');
      return []; // Return empty list on error
    }
  }
}
