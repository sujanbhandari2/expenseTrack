import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/data/repositories/goal_repository.dart';
import 'package:daily_finance_tracker/data/repositories/settings_repository.dart';
import 'package:daily_finance_tracker/data/repositories/transaction_repository.dart';
import 'package:daily_finance_tracker/domain/services/dummy_data_service.dart';
import 'package:daily_finance_tracker/domain/services/export_service.dart';
import 'package:daily_finance_tracker/domain/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(appDatabaseProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(FlutterLocalNotificationsPlugin()),
);

final dummyDataServiceProvider = Provider<DummyDataService>(
  (ref) => DummyDataService(ref.watch(transactionRepositoryProvider)),
);
