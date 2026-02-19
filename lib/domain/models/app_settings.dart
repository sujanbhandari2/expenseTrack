import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    int? id,
    @Default(false) bool dailyReminderEnabled,
    @Default('21:00') String reminderTime,
    @Default('NPR') String currency,
    @Default('') String userId,
    String? remoteId,
    DateTime? updatedAt,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
