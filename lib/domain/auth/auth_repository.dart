import 'login.dart';

abstract class AuthRepository {
  Future<Login> login(String username, String password);

  Future<void> logout();
}
