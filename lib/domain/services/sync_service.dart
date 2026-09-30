import 'package:daily_finance_tracker/data/repositories/goal_repository.dart';
import 'package:daily_finance_tracker/data/repositories/remote_goal_repository.dart';
import 'package:daily_finance_tracker/data/repositories/remote_settings_repository.dart';
import 'package:daily_finance_tracker/data/repositories/remote_transaction_repository.dart';
import 'package:daily_finance_tracker/data/repositories/settings_repository.dart';
import 'package:daily_finance_tracker/data/repositories/transaction_repository.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  SyncService({
    required TransactionRepository transactionRepository,
    required GoalRepository goalRepository,
    required SettingsRepository settingsRepository,
    required RemoteTransactionRepository remoteTransactionRepository,
    required RemoteGoalRepository remoteGoalRepository,
    required RemoteSettingsRepository remoteSettingsRepository,
  }) : _transactionRepository = transactionRepository,
       _goalRepository = goalRepository,
       _settingsRepository = settingsRepository,
       _remoteTransactionRepository = remoteTransactionRepository,
       _remoteGoalRepository = remoteGoalRepository,
       _remoteSettingsRepository = remoteSettingsRepository;

  final TransactionRepository _transactionRepository;
  final GoalRepository _goalRepository;
  final SettingsRepository _settingsRepository;
  final RemoteTransactionRepository _remoteTransactionRepository;
  final RemoteGoalRepository _remoteGoalRepository;
  final RemoteSettingsRepository _remoteSettingsRepository;
  final Map<String, Future<void>> _activeFullSyncs = {};
  final Map<String, Future<void>> _activeTransactionSyncs = {};

  Future<void> syncAll(String userId) {
    return _runSingleFlight(_activeFullSyncs, userId, () async {
      debugPrint(
        'SyncService: trying to sync all data in Firestore for userId=$userId',
      );
      await syncTransactions(userId);
      await syncGoal(userId);
      await syncSettings(userId);
    });
  }

  Future<void> syncTransactions(String userId) {
    return _runSingleFlight(_activeTransactionSyncs, userId, () async {
      debugPrint(
        'SyncService: trying to sync transactions in Firestore for userId=$userId',
      );
      final pending = await _transactionRepository.fetchPendingTransactions(
        userId,
      );
      debugPrint(
        'SyncService: pending transactions to push=${pending.length} for userId=$userId',
      );
      for (final tx in pending) {
        debugPrint(
          'SyncService: pushing transaction to Firestore '
          '(localId=${tx.id}, remoteId=${tx.remoteId ?? "new"})',
        );
        final remoteId = await _remoteTransactionRepository.upsertTransaction(
          userId,
          tx,
        );
        if (tx.id != null) {
          await _transactionRepository.markTransactionSynced(
            localId: tx.id!,
            remoteId: remoteId,
            userId: userId,
          );
        }
      }

      debugPrint(
        'SyncService: fetching transactions from Firestore for userId=$userId',
      );
      final remoteTransactions = await _remoteTransactionRepository
          .fetchTransactions(userId);
      debugPrint(
        'SyncService: pulled ${remoteTransactions.length} transactions from Firestore',
      );
      for (final tx in remoteTransactions) {
        await _transactionRepository.upsertFromRemote(
          tx.copyWith(userId: userId),
        );
      }
    });
  }

  Future<void> _runSingleFlight(
    Map<String, Future<void>> activeSyncs,
    String userId,
    Future<void> Function() operation,
  ) {
    final activeSync = activeSyncs[userId];
    if (activeSync != null) {
      debugPrint('SyncService: sync already in progress for userId=$userId');
      return activeSync;
    }

    late final Future<void> sync;
    sync = operation().whenComplete(() {
      if (identical(activeSyncs[userId], sync)) {
        activeSyncs.remove(userId);
      }
    });
    activeSyncs[userId] = sync;
    return sync;
  }

  Future<void> syncGoal(String userId) async {
    debugPrint(
      'SyncService: trying to sync goal in Firestore for userId=$userId',
    );
    final pendingGoal = await _goalRepository.fetchPendingGoal(userId);
    if (pendingGoal != null) {
      debugPrint('SyncService: pushing goal to Firestore');
      await _remoteGoalRepository.upsertGoal(userId, pendingGoal);
      if (pendingGoal.id != null) {
        await _goalRepository.markGoalSynced(
          localId: pendingGoal.id!,
          userId: userId,
          remoteId: 'goal',
        );
      }
    }

    debugPrint('SyncService: fetching goal from Firestore for userId=$userId');
    final remoteGoal = await _remoteGoalRepository.fetchGoal(userId);
    if (remoteGoal != null) {
      await _goalRepository.upsertFromRemote(
        remoteGoal.copyWith(userId: userId),
      );
    }
  }

  Future<void> syncSettings(String userId) async {
    debugPrint(
      'SyncService: trying to sync settings in Firestore for userId=$userId',
    );
    final pendingSettings = await _settingsRepository.fetchPendingSettings(
      userId,
    );
    if (pendingSettings != null) {
      debugPrint('SyncService: pushing settings to Firestore');
      await _remoteSettingsRepository.upsertSettings(userId, pendingSettings);
      await _settingsRepository.markSettingsSynced(
        userId: userId,
        remoteId: 'settings',
      );
    }

    debugPrint(
      'SyncService: fetching settings from Firestore for userId=$userId',
    );
    final remoteSettings = await _remoteSettingsRepository.fetchSettings(
      userId,
    );
    if (remoteSettings != null) {
      await _settingsRepository.upsertFromRemote(
        remoteSettings.copyWith(userId: userId),
      );
    }
  }
}
