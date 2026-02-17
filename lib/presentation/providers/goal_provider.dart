import 'package:daily_finance_tracker/domain/models/budget_goal.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalNotifier extends AsyncNotifier<BudgetGoal?> {
  @override
  Future<BudgetGoal?> build() async {
    return ref.watch(goalRepositoryProvider).getActiveGoal();
  }

  Future<void> saveWeeklyBudget(double amount) async {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final goal = BudgetGoal(weeklyBudget: amount, startDate: weekStart, isActive: true);
    await ref.read(goalRepositoryProvider).saveGoal(goal);
    state = AsyncData(goal);
  }
}

final goalProvider = AsyncNotifierProvider<GoalNotifier, BudgetGoal?>(GoalNotifier.new);
