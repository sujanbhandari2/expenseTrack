import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/providers/auth_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/goal_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/settings_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none))
      .distinct();
});

final syncLifecycleProvider = Provider<void>((ref) {
  Future<void> syncNow(String userId) async {
    try {
      await ref.read(syncServiceProvider).syncAll(userId);
      await ref.read(transactionProvider.notifier).loadInitial();
      ref.invalidate(goalProvider);
      ref.invalidate(settingsProvider);
    } catch (e, st) {
      debugPrint('syncLifecycleProvider syncNow failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> syncIfOnline(String userId) async {
    final results = await ref.read(connectivityProvider).checkConnectivity();
    final online = !results.contains(ConnectivityResult.none);
    if (online) {
      await syncNow(userId);
    }
  }

  final initialUserId = ref.read(currentUserIdProvider);
  if (initialUserId != null) {
    unawaited(syncIfOnline(initialUserId));
  }

  ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
    final userId = ref.read(currentUserIdProvider);
    final online = next.valueOrNull ?? false;
    if (userId != null && online) {
      unawaited(syncNow(userId));
    }
  });

  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
    final userId = next.valueOrNull?.uid;
    final online = ref.read(isOnlineProvider).valueOrNull ?? false;
    if (userId != null && online) {
      unawaited(syncNow(userId));
    }
  });
});
