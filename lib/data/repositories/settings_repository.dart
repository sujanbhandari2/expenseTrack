import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/domain/models/app_settings.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepository {
  SettingsRepository(this._database);

  final AppDatabase _database;

  Future<AppSettings> getSettings() async {
    final db = await _database.database;
    final rows = await db.query('settings', where: 'id = 1', limit: 1);
    if (rows.isEmpty) {
      const defaults = AppSettings();
      await saveSettings(defaults);
      return defaults;
    }
    final row = rows.first;
    return AppSettings(
      id: row['id'] as int,
      dailyReminderEnabled: (row['dailyReminderEnabled'] as int) == 1,
      reminderTime: row['reminderTime'] as String,
      currency: (row['currency'] as String?) ?? 'NPR',
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await _database.database;
    await db.insert(
      'settings',
      {
        'id': settings.id,
        'dailyReminderEnabled': settings.dailyReminderEnabled ? 1 : 0,
        'reminderTime': settings.reminderTime,
        'currency': settings.currency,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
