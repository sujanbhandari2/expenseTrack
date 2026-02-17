import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';

class TransactionRepository {
  TransactionRepository(this._database);

  final AppDatabase _database;

  Future<int> createTransaction(TransactionItem item) async {
    final db = await _database.database;
    return db.insert('transactions', _toMap(item));
  }

  Future<void> updateTransaction(TransactionItem item) async {
    final db = await _database.database;
    await db.update(
      'transactions',
      _toMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _database.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionItem>> fetchTransactionsPaged({
    required int limit,
    required int offset,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'transactions',
      orderBy: 'createdAt DESC, id DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<TransactionItem>> fetchTransactionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _database.database;
    final rows = await db.query(
      'transactions',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt ASC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<TransactionItem>> fetchTransactionsInWeek(DateTime weekStart) async {
    final end = weekStart.add(const Duration(days: 7));
    return fetchTransactionsInRange(weekStart, end);
  }

  Future<void> insertMany(List<TransactionItem> items) async {
    final db = await _database.database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('transactions', _toMap(item));
    }
    await batch.commit(noResult: true);
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
    };
  }

  TransactionItem _fromMap(Map<String, dynamic> map) {
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
    );
  }
}
