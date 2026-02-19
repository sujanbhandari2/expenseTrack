// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      id: (json['id'] as num?)?.toInt(),
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String? ?? '21:00',
      currency: json['currency'] as String? ?? 'NPR',
      userId: json['userId'] as String? ?? '',
      remoteId: json['remoteId'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.pending,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dailyReminderEnabled': instance.dailyReminderEnabled,
      'reminderTime': instance.reminderTime,
      'currency': instance.currency,
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
