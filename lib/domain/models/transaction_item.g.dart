// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionItemImpl _$$TransactionItemImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionItemImpl(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  category: json['category'] as String,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  userId: json['userId'] as String? ?? '',
  remoteId: json['remoteId'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
      SyncStatus.pending,
);

Map<String, dynamic> _$$TransactionItemImplToJson(
  _$TransactionItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount': instance.amount,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'category': instance.category,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'userId': instance.userId,
  'remoteId': instance.remoteId,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isDeleted': instance.isDeleted,
  'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
};
