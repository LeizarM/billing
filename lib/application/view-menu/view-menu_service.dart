import 'package:billing/constants/constants.dart';
import 'package:dio/dio.dart';

class ViewMenuService {
  final Dio _dio = Dio();
  final String _baseUrl = '${BASE_URL}paginaXApp';

  Future<void>? obtainViewMenu() {
    return null;
  }
}
