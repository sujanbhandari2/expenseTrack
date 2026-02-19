import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';

class TransactionRepository {
  TransactionRepository(this._database);

  final AppDatabase _database;

  Future<int> createTransaction(TransactionItem item) async {
    final db = await _database.database;
    final now = DateTime.now();
    return db.insert(
      'transactions',
      _toMap(
        item.copyWith(
          updatedAt: item.updatedAt ?? now,
          syncStatus: SyncStatus.pending,
          isDeleted: false,
        ),
      ),
    );
  }

  Future<void> updateTransaction(TransactionItem item) async {
    final db = await _database.database;
    await db.update(
      'transactions',
      _toMap(
        item.copyWith(
          updatedAt: DateTime.now(),
          syncStatus: SyncStatus.pending,
        ),
      ),
      where: 'id = ? AND userId = ?',
      whereArgs: [item.id, item.userId],
    );
  }

  Future<void> deleteTransaction({
    required int id,
    required String userId,
  }) async {
    final db = await _database.database;
    await db.update(
      'transactions',
      {
        'isDeleted': 1,
        'syncStatus': SyncStatus.pending.name,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<TransactionItem>> fetchTransactionsPaged({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'transactions',
      where: 'userId = ? AND isDeleted = 0',
      whereArgs: [userId],
      orderBy: 'createdAt DESC, id DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<TransactionItem>> fetchTransactionsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _database.database;
    final rows = await db.query(
      'transactions',
      where:
          'userId = ? AND isDeleted = 0 AND createdAt >= ? AND createdAt < ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt ASC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<TransactionItem>> fetchTransactionsInWeek(
    String userId,
    DateTime weekStart,
  ) async {
    final end = weekStart.add(const Duration(days: 7));
    return fetchTransactionsInRange(userId, weekStart, end);
  }

  Future<void> insertMany(List<TransactionItem> items) async {
    final db = await _database.database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'transactions',
        _toMap(item.copyWith(updatedAt: item.updatedAt ?? DateTime.now())),
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<TransactionItem>> fetchPendingTransactions(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'transactions',
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, SyncStatus.pending.name],
      orderBy: 'updatedAt ASC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> markTransactionSynced({
    required int localId,
    String? remoteId,
    required String userId,
  }) async {
    final db = await _database.database;
    await db.update(
      'transactions',
      {
        'syncStatus': SyncStatus.synced.name,
        'updatedAt': DateTime.now().toIso8601String(),
        if (remoteId != null) 'remoteId': remoteId,
      },
      where: 'id = ? AND userId = ?',
      whereArgs: [localId, userId],
    );
  }

  Future<void> upsertFromRemote(TransactionItem item) async {
    if (item.userId.isEmpty) return;

    final db = await _database.database;

    Map<String, dynamic>? existing;
    if (item.remoteId != null && item.remoteId!.isNotEmpty) {
      final byRemote = await db.query(
        'transactions',
        where: 'userId = ? AND remoteId = ?',
        whereArgs: [item.userId, item.remoteId],
        limit: 1,
      );
      if (byRemote.isNotEmpty) {
        existing = byRemote.first;
      }
    }

    if (existing == null && item.id != null) {
      final byId = await db.query(
        'transactions',
        where: 'id = ? AND userId = ?',
        whereArgs: [item.id, item.userId],
        limit: 1,
      );
      if (byId.isNotEmpty) {
        existing = byId.first;
      }
    }

    final remoteUpdatedAt = item.updatedAt;
    if (existing != null) {
      final localSync = existing['syncStatus'] as String?;
      final localUpdatedAtRaw = existing['updatedAt'] as String?;
      final localUpdatedAt =
          localUpdatedAtRaw == null || localUpdatedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(localUpdatedAtRaw);

      if (localSync == SyncStatus.pending.name &&
          localUpdatedAt != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt.isAfter(remoteUpdatedAt)) {
        return;
      }

      await db.update(
        'transactions',
        _toMap(item.copyWith(syncStatus: SyncStatus.synced)),
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
      return;
    }

    await db.insert(
      'transactions',
      _toMap(item.copyWith(syncStatus: SyncStatus.synced)),
    );
  }

  Map<String, dynamic> _toMap(TransactionItem item) {
    return {
      if (item.id != null) 'id': item.id,
      'title': item.title,
      'amount': item.amount,
      'type': item.type.name,
      'category': item.category,
      'note': item.note,
      'createdAt': item.createdAt.toIso8601String(),
      'userId': item.userId,
      'remoteId': item.remoteId,
      'updatedAt': (item.updatedAt ?? DateTime.now()).toIso8601String(),
      'isDeleted': item.isDeleted ? 1 : 0,
      'syncStatus': item.syncStatus.name,
    };
  }

  TransactionItem _fromMap(Map<String, dynamic> map) {
    final updatedAtRaw = map['updatedAt'] as String?;
    return TransactionItem(
      id: map['id'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: (map['type'] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: map['category'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      userId: (map['userId'] as String?) ?? '',
      remoteId: map['remoteId'] as String?,
      updatedAt: updatedAtRaw == null || updatedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(updatedAtRaw),
      isDeleted: ((map['isDeleted'] as num?) ?? 0) == 1,
      syncStatus: SyncStatus.values.firstWhere(
        (e) =>
            e.name == (map['syncStatus'] as String? ?? SyncStatus.pending.name),
        orElse: () => SyncStatus.pending,
      ),
    );
  }
}
