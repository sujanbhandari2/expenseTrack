import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'daily_finance_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            weeklyBudget REAL NOT NULL,
            startDate TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            dailyReminderEnabled INTEGER NOT NULL DEFAULT 0,
            reminderTime TEXT NOT NULL DEFAULT '21:00',
            currency TEXT NOT NULL DEFAULT 'NPR'
          )
        ''');

        await db.insert('settings', {
          'id': 1,
          'dailyReminderEnabled': 0,
          'reminderTime': '21:00',
          'currency': 'NPR',
        });
      },
    );
  }
}
