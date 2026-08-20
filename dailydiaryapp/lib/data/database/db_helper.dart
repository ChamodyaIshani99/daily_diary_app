import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(
      await getDatabasesPath(),
      'daily_diary.db',
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            date TEXT,
            imagePath TEXT,
            audioPath TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;

    return db.insert(
      'entries',
      entry.toMap(),
    );
  }

  Future<List<DiaryEntry>> getEntries() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      orderBy: 'id DESC',
    );

    return List.generate(
      maps.length,
      (index) => DiaryEntry.fromMap(maps[index]),
    );
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    final db = await database;

    return db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;

    return db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}