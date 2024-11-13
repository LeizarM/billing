// expiring_shared_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class ExpiringSharedPreferences {
  static const String _timestampSuffix = '_timestamp';
  static const int _expirationMillis = 8 * 60 * 60 * 1000; // 8 horas en milisegundos

  /// Guarda un valor booleano con una marca de tiempo.
  Future<void> setBoolWithExpiry(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('${key}_$_timestampSuffix', currentTimestamp);
  }

  /// Obtiene un valor booleano y verifica si ha expirado.
  Future<bool> getBoolWithExpiry(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool(key);
    int? timestamp = prefs.getInt('${key}_$_timestampSuffix');

    if (value != null && timestamp != null) {
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      if ((currentTimestamp - timestamp) < _expirationMillis) {
        return value;
      } else {
        // Ha expirado, eliminar los valores
        await prefs.remove(key);
        await prefs.remove('${key}_$_timestampSuffix');
        return false; // Valor por defecto después de la expiración
      }
    }

    // Si no existe el valor o el timestamp, retornar false o el valor por defecto
    return false;
  }

  /// Elimina un valor y su timestamp asociado.
  Future<void> removeBoolWithExpiry(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await prefs.remove('${key}_$_timestampSuffix');
  }
}
