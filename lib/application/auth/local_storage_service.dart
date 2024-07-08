import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/auth/login.dart';

class LocalStorageService {
  static const String USER_KEY = 'user_data';

  Future<void> saveUser(Login user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, jsonEncode(user.toJson()));
  }

  Future<Login?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(USER_KEY);
    print(userJson);
    if (userJson != null) {
      return Login.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_KEY);
  }
}
