import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'hospital_database.db');

    return await openDatabase(
      path,
      version: 3, // Incrementa la versión aquí
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Método para migración
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hospitales (
        id_hospital INTEGER PRIMARY KEY,
        nombre_hospital TEXT,
        nombre_servidor_local TEXT,
        nombre_servidor_remoto TEXT,
        user_local TEXT,
        user_remoto TEXT, 
        pass_local TEXT,
        pass_remoto TEXT,
        token_remoto TEXT,
        token_local TEXT,
        ending_task_time INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración de versión 1 a 2
      await _addColumnIfNotExists(db, 'hospitales', 'ending_task_time', 'INTEGER');
    }

    if (oldVersion < 3) {
      // Migración de versión 2 a 3
      // 1. Renombrar la tabla antigua
      await db.execute('''
        ALTER TABLE hospitales RENAME TO hospitales_old;
      ''');

      // 2. Crear la nueva tabla sin AUTOINCREMENT
      await db.execute('''
        CREATE TABLE hospitales (
          id_hospital INTEGER PRIMARY KEY,
          nombre_hospital TEXT,
          nombre_servidor_local TEXT,
          nombre_servidor_remoto TEXT,
          user_local TEXT,
          user_remoto TEXT, 
          pass_local TEXT,
          pass_remoto TEXT,
          token_remoto TEXT,
          token_local TEXT,
          ending_task_time INTEGER
        );
      ''');

      // 3. Copiar los datos de la tabla antigua a la nueva
      await db.execute('''
        INSERT INTO hospitales (
          id_hospital,
          nombre_hospital,
          nombre_servidor_local,
          nombre_servidor_remoto,
          user_local,
          user_remoto,
          pass_local,
          pass_remoto,
          token_remoto,
          token_local,
          ending_task_time
        )
        SELECT
          id_hospital,
          nombre_hospital,
          nombre_servidor_local,
          nombre_servidor_remoto,
          user_local,
          user_remoto,
          pass_local,
          pass_remoto,
          token_remoto,
          token_local,
          ending_task_time
        FROM hospitales_old;
      ''');

      // 4. Eliminar la tabla antigua
      await db.execute('''
        DROP TABLE hospitales_old;
      ''');
    }
  }

  // Funcion auxiliar para agregar una columna con una verificacion 
  Future<void> _addColumnIfNotExists(
      Database db, String tableName, String columnName, String columnDefinition) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final columnExists = columns.any((column) => column['name'] == columnName);

    if (!columnExists) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
      print('Columna $columnName agregada a la tabla $tableName.');
    } else {
      print('La columna $columnName ya existe en la tabla $tableName.');
    }
  }

  Future<int> insertHospital(Map<String, dynamic> hospital) async {
    final db = await database;
    return await db.insert('hospitales', hospital);
  }

  Future<List<Map<String, dynamic>>> getAllHospitals() async {
    final db = await database;
    return await db.query('hospitales');
  }

  Future<Map<String, dynamic>?> getHospitalById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'hospitales',
      where: 'id_hospital = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> deleteAllHospitals() async {
    final db = await database;
    await db.delete('hospitales');
  }
}
