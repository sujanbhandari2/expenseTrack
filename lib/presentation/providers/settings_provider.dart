import 'package:daily_finance_tracker/domain/models/app_settings.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<String?> updateReminder({
    required bool enabled,
    required String time,
  }) async {
    final current = state.value ?? const AppSettings();
    final updated = current.copyWith(
      dailyReminderEnabled: enabled,
      reminderTime: time,
    );

    final notificationService = ref.read(notificationServiceProvider);
    try {
      if (enabled) {
        await notificationService.scheduleDailyReminder(time);
      } else {
        await notificationService.cancelDailyReminder();
      }
    } on Exception catch (e) {
      final fallback = current.copyWith(
        dailyReminderEnabled: false,
        reminderTime: time,
      );
      await ref.read(settingsRepositoryProvider).saveSettings(fallback);
      state = AsyncData(fallback);
      final message = e.toString();
      if (message.contains('notifications_not_permitted')) {
        return 'Notification permission is blocked. Please allow notifications in system settings.';
      }
      if (message.contains('exact_alarms_not_permitted')) {
        return 'Exact alarms are blocked by Android. Reminder may be delayed or disabled.';
      }
      return 'Daily reminder could not be scheduled on this device.';
    }

    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    state = AsyncData(updated);
    return null;
  }

  Future<void> updateCurrency(String currency) async {
    final current = state.value ?? const AppSettings();
    final updated = current.copyWith(currency: currency);
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    state = AsyncData(updated);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
