import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/sync/sync_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:universal_platform/universal_platform.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  bool _hasSyncedAfterLogin = false;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('productos.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    if (UniversalPlatform.isWeb) {
      final factory = databaseFactoryWeb;
      return await factory.openDatabase(dbName);
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, dbName);
      return await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  Future<void> upsertProductos(List<Map<String, dynamic>> productos) async {
    final db = await database;
    final store = stringMapStoreFactory.store('productos');

    final apiSet = <String>{};
    final safeProductos = <String, Map<String, dynamic>>{};

    for (var producto in productos) {
      final codArticulo = producto['codArticulo']?.toString() ?? '';
      final listaPrecio = producto['listaPrecio']?.toString() ?? '';
      final db = producto['db']?.toString() ?? '';
      final codCiudad = producto['codCiudad']?.toString() ?? '';

      final key = '${codArticulo}_${listaPrecio}_${db}_$codCiudad';
      apiSet.add(key);

      safeProductos[key] = Map<String, dynamic>.from(producto)
        ..updateAll((key, value) => value ?? '');
    }

    final existingProducts = await store.findKeys(db);
    final existingSet = Set<String>.from(existingProducts);

    final toDelete = existingSet.difference(apiSet);

    await db.transaction((txn) async {
      await store
          .records(safeProductos.keys)
          .put(txn, safeProductos.values.toList());

      if (toDelete.isNotEmpty) {
        await store.records(toDelete.toList()).delete(txn);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    if (!_hasSyncedAfterLogin) {
      final userData = await LocalStorageService().getUser();
      if (userData != null) {
        await SyncService().syncProductos(userData.token, userData.codCiudad);
        _hasSyncedAfterLogin = true;
      }
    }

    final db = await database;
    final store = stringMapStoreFactory.store('productos');
    final snapshots = await store.find(db);
    return snapshots.map((snapshot) => snapshot.value).toList();
  }

  Future<List<Map<String, dynamic>>> getItemsPaginated(
      int offset, int limit) async {
    final db = await database;
    final store = stringMapStoreFactory.store('productos');
    final snapshots = await store.find(
      db,
      finder: Finder(
        offset: offset,
        limit: limit,
        sortOrders: [SortOrder('datoArt')],
      ),
    );
    return snapshots.map((snapshot) => snapshot.value).toList();
  }

  Future<List<Map<String, dynamic>>> searchItems({String? query}) async {
    final db = await database;
    final store = stringMapStoreFactory.store('productos');

    if (query == null || query.isEmpty) {
      return getItems();
    }

    final keywords =
        query.toLowerCase().split(' ').where((k) => k.isNotEmpty).toList();

    final finder = Finder(
        filter: Filter.and(keywords
            .map((keyword) => Filter.or([
                  Filter.custom((record) => record['codArticulo']
                      .toString()
                      .toLowerCase()
                      .contains(keyword)),
                  Filter.custom((record) => record['datoArt']
                      .toString()
                      .toLowerCase()
                      .contains(keyword)),
                ]))
            .toList()));

    final snapshots = await store.find(db, finder: finder);
    return snapshots.map((snapshot) => snapshot.value).toList();
  }

  void resetSyncState() {
    _hasSyncedAfterLogin = false;
  }
}
