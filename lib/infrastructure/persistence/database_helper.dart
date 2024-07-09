import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('productos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE productos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      codArticulo TEXT,
      datoArt TEXT,
      listaPrecio INTEGER,
      precio REAL,
      moneda TEXT,
      gramaje REAL,
      codigoFamilia TEXT,
      disponible INTEGER,
      unidadMedida TEXT,
      codCiudad INTEGER,
      codGrpFamiliaSap TEXT,
      ruta TEXT,
      audUsuario INTEGER,
      db TEXT
    )
    ''');

    await db.execute('''
    CREATE UNIQUE INDEX idx_producto_unique 
    ON productos (codArticulo, listaPrecio, db, codCiudad)
    ''');
  }

  Future<void> upsertProductos(List<Map<String, dynamic>> productos) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();

      // Obtiene todos los códigos de artículos existentes en la base de datos
      final existingCodes = await txn.query('productos',
          columns: ['codArticulo', 'listaPrecio', 'db', 'codCiudad']);
      final existingSet = Set<String>.from(existingCodes.map((e) =>
          '${e['codArticulo']}_${e['listaPrecio']}_${e['db']}_${e['codCiudad']}'));

      // Set para almacenar los códigos que vienen de la API
      final apiSet = <String>{};

      for (var producto in productos) {
        final key =
            '${producto['codArticulo']}_${producto['listaPrecio']}_${producto['db']}_${producto['codCiudad']}';
        apiSet.add(key);

        // Añade operación de inserción
        batch.insert(
          'productos',
          producto,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        // Añade operación de actualización
        batch.update(
          'productos',
          {
            'precio': producto['precio'],
            'disponible': producto['disponible'],
            // Añade aquí otros campos que quieras actualizar
          },
          where:
              'codArticulo = ? AND listaPrecio = ? AND db = ? AND codCiudad = ?',
          whereArgs: [
            producto['codArticulo'],
            producto['listaPrecio'],
            producto['db'],
            producto['codCiudad']
          ],
        );
      }

      // Eliminar productos que ya no existen en la API
      final toDelete = existingSet.difference(apiSet);
      for (var key in toDelete) {
        final parts = key.split('_');
        batch.delete(
          'productos',
          where:
              'codArticulo = ? AND listaPrecio = ? AND db = ? AND codCiudad = ?',
          whereArgs: [parts[0], parts[1], parts[2], parts[3]],
        );
      }

      // Ejecuta todas las operaciones del batch
      await batch.commit(noResult: true);
    });
  }

  // Para obtener los items desde sqflite
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('productos');
  }

  // Para obtener los datos de la base de datos sqlflite
  Future<List<Map<String, dynamic>>> getItemsPaginated(
      int offset, int limit) async {
    final db = await database;
    return await db.query(
      'productos',
      limit: limit,
      offset: offset,
      orderBy: 'datoArt ASC',
    );
  }

  // Para filtrar los datos por descripción o código
  Future<List<Map<String, dynamic>>> searchItems(String query) async {
    final db = await database;
    return await db.query(
      'productos',
      where: 'codArticulo LIKE ? OR datoArt LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'datoArt ASC',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS productos');
      await _createDB(db, newVersion);
    }
  }
}
