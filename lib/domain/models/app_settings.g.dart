// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      id: (json['id'] as num?)?.toInt() ?? 1,
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String? ?? '21:00',
      currency: json['currency'] as String? ?? 'NPR',
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dailyReminderEnabled': instance.dailyReminderEnabled,
      'reminderTime': instance.reminderTime,
      'currency': instance.currency,
    };
