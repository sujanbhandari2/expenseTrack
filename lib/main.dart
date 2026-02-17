import 'package:daily_finance_tracker/core/constants/app_constants.dart';
import 'package:daily_finance_tracker/core/theme/app_theme.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/screens/dashboard_screen.dart';
import 'package:daily_finance_tracker/presentation/screens/home_shell.dart';
import 'package:daily_finance_tracker/presentation/screens/management_screen.dart';
import 'package:daily_finance_tracker/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initialize();
  final settings = await container
      .read(settingsRepositoryProvider)
      .getSettings();
  if (settings.dailyReminderEnabled) {
    await notificationService.scheduleDailyReminder(settings.reminderTime);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DailyFinanceApp(),
    ),
  );
}

class DailyFinanceApp extends ConsumerWidget {
  const DailyFinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(path: '/', redirect: (_, _) => '/dashboard'),
        ShellRoute(
          builder: (context, state, child) {
            return HomeShell(location: state.uri.toString(), child: child);
          },
          routes: [
            GoRoute(path: '/dashboard', builder: _dashboardBuilder),
            GoRoute(path: '/management', builder: _managementBuilder),
            GoRoute(path: '/settings', builder: _settingsBuilder),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

Widget _dashboardBuilder(BuildContext context, GoRouterState state) {
  return const DashboardScreen();
}

Widget _managementBuilder(BuildContext context, GoRouterState state) {
  return const ManagementScreen();
}

Widget _settingsBuilder(BuildContext context, GoRouterState state) {
  return const SettingsScreen();
}
