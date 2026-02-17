import 'dart:math';

import 'package:daily_finance_tracker/domain/models/budget_goal.dart';
import 'package:daily_finance_tracker/domain/models/dashboard_filter.dart';
import 'package:daily_finance_tracker/domain/models/dashboard_stats.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:daily_finance_tracker/presentation/providers/goal_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardFilterProvider = StateProvider<DashboardFilter>(
  (ref) => DashboardFilter.monthly,
);

class DashboardBundle {
  const DashboardBundle({
    required this.stats,
    required this.transactions,
    required this.categoryBreakdown,
    required this.dailyExpensePoints,
    required this.budgetMessage,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final DashboardStats stats;
  final List<TransactionItem> transactions;
  final Map<String, double> categoryBreakdown;
  final List<MapEntry<DateTime, double>> dailyExpensePoints;
  final String budgetMessage;
  final DateTime rangeStart;
  final DateTime rangeEnd;
}

final dashboardStatsProvider = FutureProvider<DashboardBundle>((ref) async {
  final filter = ref.watch(dashboardFilterProvider);
  ref.watch(transactionProvider);
  final goalAsync = ref.watch(goalProvider);
  final txnNotifier = ref.watch(transactionProvider.notifier);

  final now = DateTime.now();
  final (start, end) = _rangeFor(filter, now);
  final (prevStart, prevEnd) = _previousRange(start, end);

  final transactions = await txnNotifier.getInRange(start, end);
  final previousTransactions = await txnNotifier.getInRange(prevStart, prevEnd);

  final goal = goalAsync.valueOrNull;
  final weekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final weekTransactions = await txnNotifier.getCurrentWeek(weekStart);

  final stats = _computeStats(transactions, previousTransactions, goal, weekTransactions);

  final byCategory = <String, double>{};
  for (final tx in transactions.where((e) => e.type == TransactionType.expense)) {
    byCategory.update(tx.category, (v) => v + tx.amount, ifAbsent: () => tx.amount);
  }

  final byDay = <DateTime, double>{};
  for (final tx in transactions.where((e) => e.type == TransactionType.expense)) {
    final day = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
    byDay.update(day, (v) => v + tx.amount, ifAbsent: () => tx.amount);
  }

  final dailyPoints = byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  final budgetMessage = _budgetMessage(stats.weeklyBudgetUsed);

  return DashboardBundle(
    stats: stats,
    transactions: transactions,
    categoryBreakdown: byCategory,
    dailyExpensePoints: dailyPoints,
    budgetMessage: budgetMessage,
    rangeStart: start,
    rangeEnd: end,
  );
});

(String, String) dashboardKpiNames() => ('Income', 'Expense');

(DateTime, DateTime) _rangeFor(DashboardFilter filter, DateTime now) {
  final todayStart = DateTime(now.year, now.month, now.day);
  switch (filter) {
    case DashboardFilter.daily:
      return (todayStart, todayStart.add(const Duration(days: 1)));
    case DashboardFilter.monthly:
      return (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 1));
    case DashboardFilter.sixMonths:
      return (DateTime(now.year, now.month - 5, 1), DateTime(now.year, now.month + 1, 1));
    case DashboardFilter.yearly:
      return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
  }
}

(DateTime, DateTime) _previousRange(DateTime start, DateTime end) {
  final diff = end.difference(start);
  return (start.subtract(diff), start);
}

DashboardStats _computeStats(
  List<TransactionItem> current,
  List<TransactionItem> previous,
  BudgetGoal? goal,
  List<TransactionItem> weekTransactions,
) {
  final totalIncome = current
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (sum, t) => sum + t.amount);
  final totalExpense = current
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.amount);
  final balance = totalIncome - totalExpense;
  final savingsRate = totalIncome == 0 ? 0.0 : (balance / totalIncome) * 100;

  final dayCount = max(1, current
      .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
      .toSet()
      .length);
  final averageDailyExpense = totalExpense / dayCount;

  final categoryMap = <String, double>{};
  for (final tx in current.where((t) => t.type == TransactionType.expense)) {
    categoryMap.update(tx.category, (v) => v + tx.amount, ifAbsent: () => tx.amount);
  }

  String highestCategory = '-';
  double highest = 0;
  for (final entry in categoryMap.entries) {
    if (entry.value > highest) {
      highest = entry.value;
      highestCategory = entry.key;
    }
  }

  final prevExpense = previous
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.amount);
  final expenseGrowth =
      prevExpense == 0 ? 0.0 : ((totalExpense - prevExpense) / prevExpense) * 100;

  final weekSpent = weekTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.amount);
  final weeklyBudget = goal?.weeklyBudget ?? 0.0;
  final weeklyBudgetUsed = weeklyBudget == 0 ? 0.0 : (weekSpent / weeklyBudget) * 100;
  final weekRemaining = weeklyBudget == 0 ? 0.0 : weeklyBudget - weekSpent;

  final transactionCount = current.length;
  final expenseToIncomeRatio = totalIncome == 0 ? 0.0 : (totalExpense / totalIncome) * 100;

  return DashboardStats(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    balance: balance,
    savingsRate: savingsRate,
    averageDailyExpense: averageDailyExpense,
    highestCategory: highestCategory,
    expenseGrowth: expenseGrowth,
    weeklyBudgetUsed: weeklyBudgetUsed,
    transactionCount: transactionCount,
    expenseToIncomeRatio: expenseToIncomeRatio,
    weekSpent: weekSpent,
    weekRemaining: weekRemaining,
  );
}

String _budgetMessage(double usedPercent) {
  if (usedPercent >= 100) {
    return 'Alert: You have exceeded 100% of your weekly budget.';
  }
  if (usedPercent >= 80) {
    return 'Warning: You have used ${usedPercent.toStringAsFixed(0)}% of your weekly budget.';
  }
  return 'Today you have used ${usedPercent.toStringAsFixed(0)}% of your weekly budget.';
}
