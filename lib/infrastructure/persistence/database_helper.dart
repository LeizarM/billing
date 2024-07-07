import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        token TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        codArticulo TEXT PRIMARY KEY,
        datoArt TEXT,
        listaPrecio INTEGER,
        precio REAL,
        moneda TEXT,
        codigoFamilia TEXT,
        disponible INTEGER,
        unidadMedida TEXT,
        codGrupoFamiliaSap TEXT,
        ruta TEXT,
        db TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE productos(
          codArticulo TEXT PRIMARY KEY,
          datoArt TEXT,
          listaPrecio INTEGER,
          precio REAL,
          moneda TEXT,
          codigoFamilia TEXT,
          disponible INTEGER,
          unidadMedida TEXT,
          codGrupoFamiliaSap TEXT,
          ruta TEXT,
          db TEXT
        )
      ''');
    }
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
  }
}
