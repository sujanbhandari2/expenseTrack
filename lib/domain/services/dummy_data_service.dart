import 'dart:math';

import 'package:daily_finance_tracker/core/constants/categories.dart';
import 'package:daily_finance_tracker/data/repositories/transaction_repository.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';

class DummyDataService {
  DummyDataService(this._repository);

  final TransactionRepository _repository;

  Future<void> insertDummyData({int days = 30}) async {
    final random = Random();
    final now = DateTime.now();
    final items = <TransactionItem>[];

    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final expenseCount = random.nextInt(3) + 1;
      for (var e = 0; e < expenseCount; e++) {
        items.add(
          TransactionItem(
            title: 'Expense ${i + e + 1}',
            amount: random.nextDouble() * 2000 + 100,
            type: TransactionType.expense,
            category: expenseCategories[random.nextInt(expenseCategories.length)],
            note: random.nextBool() ? 'Auto generated' : null,
            createdAt: date.subtract(Duration(hours: random.nextInt(12))),
          ),
        );
      }

      if (random.nextBool()) {
        items.add(
          TransactionItem(
            title: 'Income ${i + 1}',
            amount: random.nextDouble() * 6000 + 2000,
            type: TransactionType.income,
            category: incomeCategories[random.nextInt(incomeCategories.length)],
            note: 'Auto generated',
            createdAt: date.subtract(Duration(hours: random.nextInt(8))),
          ),
        );
      }
    }

    await _repository.insertMany(items);
  }
}
