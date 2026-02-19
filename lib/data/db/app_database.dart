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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            createdAt TEXT NOT NULL,
            userId TEXT NOT NULL,
            remoteId TEXT,
            updatedAt TEXT,
            isDeleted INTEGER NOT NULL DEFAULT 0,
            syncStatus TEXT NOT NULL DEFAULT 'pending'
          )
        ''');

        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            weeklyBudget REAL NOT NULL,
            startDate TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            userId TEXT NOT NULL,
            remoteId TEXT,
            updatedAt TEXT,
            syncStatus TEXT NOT NULL DEFAULT 'pending'
          )
        ''');

        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dailyReminderEnabled INTEGER NOT NULL DEFAULT 0,
            reminderTime TEXT NOT NULL DEFAULT '21:00',
            currency TEXT NOT NULL DEFAULT 'NPR',
            userId TEXT NOT NULL,
            remoteId TEXT,
            updatedAt TEXT,
            syncStatus TEXT NOT NULL DEFAULT 'pending'
          )
        ''');

        await _createIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
      },
    );
  }

  Future<void> _migrateToV2(Database db) async {
    await _safeAddColumn(db, 'transactions', 'userId TEXT NOT NULL DEFAULT ""');
    await _safeAddColumn(db, 'transactions', 'remoteId TEXT');
    await _safeAddColumn(db, 'transactions', 'updatedAt TEXT');
    await _safeAddColumn(
      db,
      'transactions',
      'isDeleted INTEGER NOT NULL DEFAULT 0',
    );
    await _safeAddColumn(
      db,
      'transactions',
      'syncStatus TEXT NOT NULL DEFAULT "synced"',
    );

    await _safeAddColumn(db, 'goals', 'userId TEXT NOT NULL DEFAULT ""');
    await _safeAddColumn(db, 'goals', 'remoteId TEXT');
    await _safeAddColumn(db, 'goals', 'updatedAt TEXT');
    await _safeAddColumn(
      db,
      'goals',
      'syncStatus TEXT NOT NULL DEFAULT "synced"',
    );

    await _safeAddColumn(db, 'settings', 'userId TEXT NOT NULL DEFAULT ""');
    await _safeAddColumn(db, 'settings', 'remoteId TEXT');
    await _safeAddColumn(db, 'settings', 'updatedAt TEXT');
    await _safeAddColumn(
      db,
      'settings',
      'syncStatus TEXT NOT NULL DEFAULT "synced"',
    );

    await _createIndexes(db);
  }

  Future<void> _safeAddColumn(
    Database db,
    String table,
    String definition,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $definition');
    } catch (_) {}
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tx_user_date ON transactions(userId, createdAt DESC)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_tx_user_remote ON transactions(userId, remoteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_goal_user_active ON goals(userId, isActive)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_goal_user_remote ON goals(userId, remoteId)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_settings_user ON settings(userId)',
    );
  }
}
