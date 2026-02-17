// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetGoalImpl _$$BudgetGoalImplFromJson(Map<String, dynamic> json) =>
    _$BudgetGoalImpl(
      id: (json['id'] as num?)?.toInt(),
      weeklyBudget: (json['weeklyBudget'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$BudgetGoalImplToJson(_$BudgetGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weeklyBudget': instance.weeklyBudget,
      'startDate': instance.startDate.toIso8601String(),
      'isActive': instance.isActive,
    };
