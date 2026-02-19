import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/domain/models/app_settings.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepository {
  SettingsRepository(this._database);

  final AppDatabase _database;

  Future<AppSettings> getSettings(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'settings',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      final defaults = AppSettings(
        userId: userId,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );
      await saveSettings(defaults);
      return defaults;
    }

    return _fromMap(rows.first);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await _database.database;
    await db.insert('settings', {
      if (settings.id != null) 'id': settings.id,
      'dailyReminderEnabled': settings.dailyReminderEnabled ? 1 : 0,
      'reminderTime': settings.reminderTime,
      'currency': settings.currency,
      'userId': settings.userId,
      'remoteId': settings.remoteId,
      'updatedAt': (settings.updatedAt ?? DateTime.now()).toIso8601String(),
      'syncStatus': settings.syncStatus.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppSettings?> fetchPendingSettings(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'settings',
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, SyncStatus.pending.name],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> markSettingsSynced({
    required String userId,
    String? remoteId,
  }) async {
    final db = await _database.database;
    await db.update(
      'settings',
      {
        'syncStatus': SyncStatus.synced.name,
        'updatedAt': DateTime.now().toIso8601String(),
        if (remoteId != null) 'remoteId': remoteId,
      },
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> upsertFromRemote(AppSettings settings) async {
    final db = await _database.database;
    final existing = await db.query(
      'settings',
      where: 'userId = ?',
      whereArgs: [settings.userId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final local = existing.first;
      final localSync = local['syncStatus'] as String?;
      final localUpdatedAtRaw = local['updatedAt'] as String?;
      final localUpdatedAt =
          localUpdatedAtRaw == null || localUpdatedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(localUpdatedAtRaw);

      if (localSync == SyncStatus.pending.name &&
          localUpdatedAt != null &&
          settings.updatedAt != null &&
          localUpdatedAt.isAfter(settings.updatedAt!)) {
        return;
      }

      await db.update(
        'settings',
        {
          'dailyReminderEnabled': settings.dailyReminderEnabled ? 1 : 0,
          'reminderTime': settings.reminderTime,
          'currency': settings.currency,
          'remoteId': settings.remoteId,
          'updatedAt': (settings.updatedAt ?? DateTime.now()).toIso8601String(),
          'syncStatus': SyncStatus.synced.name,
        },
        where: 'id = ?',
        whereArgs: [local['id']],
      );
      return;
    }

    await db.insert('settings', {
      'dailyReminderEnabled': settings.dailyReminderEnabled ? 1 : 0,
      'reminderTime': settings.reminderTime,
      'currency': settings.currency,
      'userId': settings.userId,
      'remoteId': settings.remoteId,
      'updatedAt': (settings.updatedAt ?? DateTime.now()).toIso8601String(),
      'syncStatus': SyncStatus.synced.name,
    });
  }

  AppSettings _fromMap(Map<String, dynamic> row) {
    final updatedAtRaw = row['updatedAt'] as String?;
    return AppSettings(
      id: row['id'] as int?,
      dailyReminderEnabled: (row['dailyReminderEnabled'] as int) == 1,
      reminderTime: row['reminderTime'] as String,
      currency: (row['currency'] as String?) ?? 'NPR',
      userId: (row['userId'] as String?) ?? '',
      remoteId: row['remoteId'] as String?,
      updatedAt: updatedAtRaw == null || updatedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(updatedAtRaw),
      syncStatus: SyncStatus.values.firstWhere(
        (e) =>
            e.name == (row['syncStatus'] as String? ?? SyncStatus.pending.name),
        orElse: () => SyncStatus.pending,
      ),
    );
  }
}
