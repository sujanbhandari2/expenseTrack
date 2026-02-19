import 'package:daily_finance_tracker/domain/models/budget_goal.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalNotifier extends AsyncNotifier<BudgetGoal?> {
  String _cloudSyncFailureMessage() {
    return 'Goal saved locally, but Firebase sync failed. '
        'Check internet/Firestore rules and try again.';
  }

  @override
  Future<BudgetGoal?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return null;

    try {
      await ref.read(syncServiceProvider).syncGoal(userId);
    } catch (e, st) {
      debugPrint('GoalNotifier.build syncGoal failed: $e');
      debugPrintStack(stackTrace: st);
    }

    return ref.watch(goalRepositoryProvider).getActiveGoal(userId);
  }

  Future<String?> saveWeeklyBudget(double amount) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return 'Please sign in first.';

    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final goal = BudgetGoal(
      weeklyBudget: amount,
      startDate: weekStart,
      isActive: true,
      userId: userId,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await ref.read(goalRepositoryProvider).saveGoal(goal);

    String? syncMessage;
    try {
      await ref.read(syncServiceProvider).syncGoal(userId);
    } catch (e, st) {
      debugPrint('saveWeeklyBudget syncGoal failed: $e');
      debugPrintStack(stackTrace: st);
      syncMessage = _cloudSyncFailureMessage();
    }

    final refreshed = await ref
        .read(goalRepositoryProvider)
        .getActiveGoal(userId);
    state = AsyncData(refreshed);
    return syncMessage;
  }
}

final goalProvider = AsyncNotifierProvider<GoalNotifier, BudgetGoal?>(
  GoalNotifier.new,
);
