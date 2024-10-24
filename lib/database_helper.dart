import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'aquarium.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE settings(id INTEGER PRIMARY KEY, fishCount INTEGER, speed REAL, color INTEGER)", // Store color as INTEGER
      );
    });
  }

  Future<void> insertSettings(int fishCount, double speed, int color) async {
    final db = await database;
    await db.insert(
      'settings',
      {
        'fishCount': fishCount,
        'speed': speed,
        'color': color, 
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    return maps.isNotEmpty ? maps.first : null;
  }
}
