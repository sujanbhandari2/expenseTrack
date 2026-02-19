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
      userId: json['userId'] as String? ?? '',
      remoteId: json['remoteId'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.pending,
    );

Map<String, dynamic> _$$BudgetGoalImplToJson(_$BudgetGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weeklyBudget': instance.weeklyBudget,
      'startDate': instance.startDate.toIso8601String(),
      'isActive': instance.isActive,
      'userId': instance.userId,
      'remoteId': instance.remoteId,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
};
