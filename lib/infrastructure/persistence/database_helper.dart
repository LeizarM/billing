import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:universal_platform/universal_platform.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

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

    // Create a Set of keys from the API data
    final apiSet = <String>{};
    final safeProductos = <String, Map<String, dynamic>>{};

    for (var producto in productos) {
      final codArticulo = producto['codArticulo']?.toString() ?? '';
      final listaPrecio = producto['listaPrecio']?.toString() ?? '';
      final db = producto['db']?.toString() ?? '';
      final codCiudad = producto['codCiudad']?.toString() ?? '';

      final key = '${codArticulo}_${listaPrecio}_${db}_${codCiudad}';
      apiSet.add(key);

      // Ensure all values are non-null and store in a map
      safeProductos[key] = Map<String, dynamic>.from(producto)
        ..updateAll((key, value) => value ?? '');
    }

    // Perform the upsert and deletion within a single transaction
    await db.transaction((txn) async {
      // Get all existing products' keys
      final existingProducts = await store.findKeys(txn);
      final existingSet = Set<String>.from(existingProducts);

      // Upsert all API products in batch
      await store
          .records(safeProductos.keys)
          .put(txn, safeProductos.values.toList());

      // Find and delete the products that no longer exist in the API
      final toDelete = existingSet.difference(apiSet);
      if (toDelete.isNotEmpty) {
        await store.records(toDelete).delete(txn);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getItems() async {
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

  Future<List<Map<String, dynamic>>> searchItems(String query) async {
    final db = await database;
    final store = stringMapStoreFactory.store('productos');
    final snapshots = await store.find(
      db,
      finder: Finder(
        filter: Filter.or([
          Filter.custom((record) => record['codArticulo']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())),
          Filter.custom((record) => record['datoArt']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())),
        ]),
        sortOrders: [SortOrder('datoArt')],
      ),
    );
    return snapshots.map((snapshot) => snapshot.value).toList();
  }
}
