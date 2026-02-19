import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_goal.freezed.dart';
part 'budget_goal.g.dart';

@freezed
class BudgetGoal with _$BudgetGoal {
  const factory BudgetGoal({
    int? id,
    required double weeklyBudget,
    required DateTime startDate,
    @Default(true) bool isActive,
    @Default('') String userId,
    String? remoteId,
    DateTime? updatedAt,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
  }) = _BudgetGoal;

  factory BudgetGoal.fromJson(Map<String, dynamic> json) =>
      _$BudgetGoalFromJson(json);
}
