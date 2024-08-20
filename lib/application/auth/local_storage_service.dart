import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/auth/login.dart';

class LocalStorageService {
  static const String USER_KEY = 'user_data';
  static const String KEY_TOKEN = 'user_token';
  static const String KEY_COD_USUARIO = 'user_cod_usuario';

  Future<void> saveUser(Login user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, jsonEncode(user.toJson()));
    await prefs.setString(KEY_TOKEN, user.token);
    await prefs.setInt(KEY_COD_USUARIO, user.codUsuario);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_TOKEN);
  }

  Future<Login?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(USER_KEY);

    if (userJson != null) {
      return Login.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<int?> getCodUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_COD_USUARIO);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_KEY);
    await prefs.remove(KEY_TOKEN);
    await prefs.remove(KEY_COD_USUARIO);
  }
}
