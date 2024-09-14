import 'package:billing/domain/view-menu/view-menu.dart';

abstract class VistaRepository {
  Future<List<Vista>> obtainViewMenu(int codUsuario);
}
