import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE productos (
      codArticulo TEXT PRIMARY KEY,
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
  }

  Future<void> upsertProductos(List<Map<String, dynamic>> productos) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var producto in productos) {
        await txn.insert(
          'productos',
          producto,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    print('${productos.length} productos insertados o actualizados en la base de datos');
  }
}