import 'package:daily_finance_tracker/domain/models/app_settings.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  String _cloudSyncFailureMessage() {
    return 'Settings saved locally, but Firebase sync failed. '
        'Check internet/Firestore rules and try again.';
  }

  @override
  Future<AppSettings> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const AppSettings();

    try {
      await ref.read(syncServiceProvider).syncSettings(userId);
    } catch (e, st) {
      debugPrint('SettingsNotifier.build syncSettings failed: $e');
      debugPrintStack(stackTrace: st);
    }

    final settings = await ref
        .watch(settingsRepositoryProvider)
        .getSettings(userId);

    final notificationService = ref.read(notificationServiceProvider);
    try {
      if (settings.dailyReminderEnabled) {
        await notificationService.scheduleDailyReminder(settings.reminderTime);
      } else {
        await notificationService.cancelDailyReminder();
      }
    } catch (e, st) {
      debugPrint('SettingsNotifier.build notification sync failed: $e');
      debugPrintStack(stackTrace: st);
    }

    return settings;
  }

  Future<String?> updateReminder({
    required bool enabled,
    required String time,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return 'Please sign in first.';

    final current = state.value ?? AppSettings(userId: userId);
    final updated = current.copyWith(
      userId: userId,
      dailyReminderEnabled: enabled,
      reminderTime: time,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
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
        userId: userId,
        dailyReminderEnabled: false,
        reminderTime: time,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
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
    String? syncMessage;
    try {
      await ref.read(syncServiceProvider).syncSettings(userId);
    } catch (e, st) {
      debugPrint('updateReminder syncSettings failed: $e');
      debugPrintStack(stackTrace: st);
      syncMessage = _cloudSyncFailureMessage();
    }
    final refreshed = await ref
        .read(settingsRepositoryProvider)
        .getSettings(userId);
    state = AsyncData(refreshed);
    return syncMessage;
  }

  Future<String?> updateCurrency(String currency) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return 'Please sign in first.';

    final current = state.value ?? AppSettings(userId: userId);
    final updated = current.copyWith(
      userId: userId,
      currency: currency,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    String? syncMessage;
    try {
      await ref.read(syncServiceProvider).syncSettings(userId);
    } catch (e, st) {
      debugPrint('updateCurrency syncSettings failed: $e');
      debugPrintStack(stackTrace: st);
      syncMessage = _cloudSyncFailureMessage();
    }

    final refreshed = await ref
        .read(settingsRepositoryProvider)
        .getSettings(userId);
    state = AsyncData(refreshed);
    return syncMessage;
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
