import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/domain/models/budget_goal.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';

class GoalRepository {
  GoalRepository(this._database);

  final AppDatabase _database;

  Future<BudgetGoal?> getActiveGoal(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'goals',
      where: 'userId = ? AND isActive = 1',
      whereArgs: [userId],
      orderBy: 'startDate DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> saveGoal(BudgetGoal goal) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.update(
        'goals',
        {'isActive': 0, 'syncStatus': SyncStatus.pending.name},
        where: 'userId = ?',
        whereArgs: [goal.userId],
      );

      Map<String, Object?>? target;
      final byRemote = await txn.query(
        'goals',
        where: 'userId = ? AND remoteId = ?',
        whereArgs: [goal.userId, 'goal'],
        limit: 1,
      );
      if (byRemote.isNotEmpty) {
        target = byRemote.first;
      } else {
        final latest = await txn.query(
          'goals',
          where: 'userId = ?',
          whereArgs: [goal.userId],
          orderBy: 'id DESC',
          limit: 1,
        );
        if (latest.isNotEmpty) {
          target = latest.first;
        }
      }

      final values = {
        'weeklyBudget': goal.weeklyBudget,
        'startDate': goal.startDate.toIso8601String(),
        'isActive': goal.isActive ? 1 : 0,
        'userId': goal.userId,
        'remoteId': target?['remoteId'] ?? goal.remoteId,
        'updatedAt': (goal.updatedAt ?? DateTime.now()).toIso8601String(),
        'syncStatus': SyncStatus.pending.name,
      };

      if (target != null) {
        await txn.update(
          'goals',
          values,
          where: 'id = ?',
          whereArgs: [target['id']],
        );
        return;
      }

      await txn.insert('goals', values);
    });
  }

  Future<BudgetGoal?> fetchPendingGoal(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'goals',
      where: 'userId = ? AND isActive = 1 AND syncStatus = ?',
      whereArgs: [userId, SyncStatus.pending.name],
      orderBy: 'updatedAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> markGoalSynced({
    required int localId,
    required String userId,
    String? remoteId,
  }) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      if (remoteId != null && remoteId.isNotEmpty) {
        await txn.update(
          'goals',
          {'remoteId': null},
          where: 'userId = ? AND remoteId = ? AND id != ?',
          whereArgs: [userId, remoteId, localId],
        );
      }

      await txn.update(
        'goals',
        {
          'syncStatus': SyncStatus.synced.name,
          'updatedAt': DateTime.now().toIso8601String(),
          if (remoteId != null) 'remoteId': remoteId,
        },
        where: 'id = ? AND userId = ?',
        whereArgs: [localId, userId],
      );
    });
  }

  Future<void> upsertFromRemote(BudgetGoal goal) async {
    final db = await _database.database;
    Map<String, Object?>? existing;
    if (goal.remoteId != null && goal.remoteId!.isNotEmpty) {
      final byRemote = await db.query(
        'goals',
        where: 'userId = ? AND remoteId = ?',
        whereArgs: [goal.userId, goal.remoteId],
        limit: 1,
      );
      if (byRemote.isNotEmpty) {
        existing = byRemote.first;
      }
    }

    if (existing == null) {
      final active = await db.query(
        'goals',
        where: 'userId = ? AND isActive = 1',
        whereArgs: [goal.userId],
        limit: 1,
      );
      if (active.isNotEmpty) {
        existing = active.first;
      }
    }

    if (existing != null) {
      final local = existing;
      final localSync = local['syncStatus'] as String?;
      final localUpdatedAtRaw = local['updatedAt'] as String?;
      final localUpdatedAt =
          localUpdatedAtRaw == null || localUpdatedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(localUpdatedAtRaw);

      if (localSync == SyncStatus.pending.name &&
          localUpdatedAt != null &&
          goal.updatedAt != null &&
          localUpdatedAt.isAfter(goal.updatedAt!)) {
        return;
      }

      await db.transaction((txn) async {
        if (goal.remoteId != null && goal.remoteId!.isNotEmpty) {
          await txn.update(
            'goals',
            {'remoteId': null},
            where: 'userId = ? AND remoteId = ? AND id != ?',
            whereArgs: [goal.userId, goal.remoteId, local['id']],
          );
        }

        await txn.update(
          'goals',
          {
            'weeklyBudget': goal.weeklyBudget,
            'startDate': goal.startDate.toIso8601String(),
            'isActive': goal.isActive ? 1 : 0,
            'remoteId': goal.remoteId,
            'updatedAt': (goal.updatedAt ?? DateTime.now()).toIso8601String(),
            'syncStatus': SyncStatus.synced.name,
          },
          where: 'id = ?',
          whereArgs: [local['id']],
        );
      });
      return;
    }

    await db.insert('goals', {
      'weeklyBudget': goal.weeklyBudget,
      'startDate': goal.startDate.toIso8601String(),
      'isActive': goal.isActive ? 1 : 0,
      'userId': goal.userId,
      'remoteId': goal.remoteId,
      'updatedAt': (goal.updatedAt ?? DateTime.now()).toIso8601String(),
      'syncStatus': SyncStatus.synced.name,
    });
  }

  BudgetGoal _fromMap(Map<String, dynamic> map) {
    final updatedAtRaw = map['updatedAt'] as String?;
    return BudgetGoal(
      id: map['id'] as int,
      weeklyBudget: (map['weeklyBudget'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate'] as String),
      isActive: (map['isActive'] as int) == 1,
      userId: (map['userId'] as String?) ?? '',
      remoteId: map['remoteId'] as String?,
      updatedAt: updatedAtRaw == null || updatedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(updatedAtRaw),
      syncStatus: SyncStatus.values.firstWhere(
        (e) =>
            e.name == (map['syncStatus'] as String? ?? SyncStatus.pending.name),
        orElse: () => SyncStatus.pending,
      ),
    );
  }
}
