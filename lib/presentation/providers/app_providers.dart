import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/data/repositories/goal_repository.dart';
import 'package:daily_finance_tracker/data/repositories/remote_goal_repository.dart';
import 'package:daily_finance_tracker/data/repositories/remote_settings_repository.dart';
import 'package:daily_finance_tracker/data/repositories/remote_transaction_repository.dart';
import 'package:daily_finance_tracker/data/repositories/settings_repository.dart';
import 'package:daily_finance_tracker/data/repositories/transaction_repository.dart';
import 'package:daily_finance_tracker/domain/services/dummy_data_service.dart';
import 'package:daily_finance_tracker/domain/services/export_service.dart';
import 'package:daily_finance_tracker/domain/services/notification_service.dart';
import 'package:daily_finance_tracker/domain/services/sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(appDatabaseProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final remoteTransactionRepositoryProvider =
    Provider<RemoteTransactionRepository>(
      (ref) => RemoteTransactionRepository(ref.watch(firestoreProvider)),
    );

final remoteGoalRepositoryProvider = Provider<RemoteGoalRepository>(
  (ref) => RemoteGoalRepository(ref.watch(firestoreProvider)),
);

final remoteSettingsRepositoryProvider = Provider<RemoteSettingsRepository>(
  (ref) => RemoteSettingsRepository(ref.watch(firestoreProvider)),
);

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    goalRepository: ref.watch(goalRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    remoteTransactionRepository: ref.watch(remoteTransactionRepositoryProvider),
    remoteGoalRepository: ref.watch(remoteGoalRepositoryProvider),
    remoteSettingsRepository: ref.watch(remoteSettingsRepositoryProvider),
  );
});

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(FlutterLocalNotificationsPlugin()),
);

final dummyDataServiceProvider = Provider<DummyDataService>(
  (ref) => DummyDataService(ref.watch(transactionRepositoryProvider)),
);

final userBootstrapProvider = FutureProvider.family<void, String>((
  ref,
  userId,
) async {
  try {
    await ref.read(syncServiceProvider).syncAll(userId);
  } catch (e, st) {
    debugPrint('userBootstrapProvider syncAll failed: $e');
    debugPrintStack(stackTrace: st);
  }

  final settings = await ref
      .read(settingsRepositoryProvider)
      .getSettings(userId);
  final notificationService = ref.read(notificationServiceProvider);
  try {
    if (settings.dailyReminderEnabled) {
      await notificationService.scheduleDailyReminder(settings.reminderTime);
    } else {
      await notificationService.cancelDailyReminder();
    }
  } catch (e, st) {
    debugPrint('userBootstrapProvider notification init failed: $e');
    debugPrintStack(stackTrace: st);
  }
});
