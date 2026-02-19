import 'package:daily_finance_tracker/data/repositories/transaction_repository.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:daily_finance_tracker/domain/services/sync_service.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionListState {
  const TransactionListState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
  });

  final List<TransactionItem> items;
  final bool isLoading;
  final bool hasMore;
  final int page;

  TransactionListState copyWith({
    List<TransactionItem>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return TransactionListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionListState> {
  TransactionNotifier(this.ref, this._repository, this._syncService)
    : super(const TransactionListState()) {
    loadInitial();
  }

  final Ref ref;
  final TransactionRepository _repository;
  final SyncService _syncService;
  static const _pageSize = 25;

  String? get _userId => ref.read(currentUserIdProvider);

  String _cloudSyncFailureMessage() {
    return 'Saved locally, but Firebase sync failed. '
        'Check internet/Firestore rules and try again.';
  }

  Future<void> loadInitial() async {
    final userId = _userId;
    if (userId == null) {
      state = const TransactionListState(items: [], hasMore: false);
      return;
    }

    await _reload(userId: userId, page: 0, withLoading: true);

    try {
      await _syncService.syncTransactions(userId);
      await _reload(userId: userId, page: 0, withLoading: false);
    } catch (e, st) {
      debugPrint('loadInitial syncTransactions failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> loadMore() async {
    final userId = _userId;
    if (userId == null || state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final offset = state.page * _pageSize;
    final next = await _repository.fetchTransactionsPaged(
      userId: userId,
      limit: _pageSize,
      offset: offset,
    );

    state = state.copyWith(
      isLoading: false,
      items: [...state.items, ...next],
      hasMore: next.length == _pageSize,
      page: state.page + 1,
    );
  }

  Future<String?> addTransaction(TransactionItem item) async {
    final userId = _userId;
    if (userId == null) return 'Please sign in first.';

    await _repository.createTransaction(
      item.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        isDeleted: false,
      ),
    );

    String? syncMessage;
    try {
      await _syncService.syncTransactions(userId);
    } catch (e, st) {
      debugPrint('addTransaction syncTransactions failed: $e');
      debugPrintStack(stackTrace: st);
      syncMessage = _cloudSyncFailureMessage();
    }

    await _reload(userId: userId, page: 0, withLoading: false);
    return syncMessage;
  }

  Future<String?> updateTransaction(TransactionItem item) async {
    final userId = _userId;
    if (userId == null) return 'Please sign in first.';

    await _repository.updateTransaction(
      item.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      ),
    );

    String? syncMessage;
    try {
      await _syncService.syncTransactions(userId);
    } catch (e, st) {
      debugPrint('updateTransaction syncTransactions failed: $e');
      debugPrintStack(stackTrace: st);
      syncMessage = _cloudSyncFailureMessage();
    }

    await _reload(userId: userId, page: 0, withLoading: false);
    return syncMessage;
  }

  Future<String?> deleteTransaction(int id) async {
    final userId = _userId;
    if (userId == null) return 'Please sign in first.';

    await _repository.deleteTransaction(id: id, userId: userId);

    String? syncMessage;
    try {
      await _syncService.syncTransactions(userId);
    } catch (e, st) {
      debugPrint('deleteTransaction syncTransactions failed: $e');
      debugPrintStack(stackTrace: st);
      syncMessage = _cloudSyncFailureMessage();
    }

    await _reload(userId: userId, page: 0, withLoading: false);
    return syncMessage;
  }

  Future<List<TransactionItem>> getInRange(DateTime start, DateTime end) async {
    final userId = _userId;
    if (userId == null) return [];
    return _repository.fetchTransactionsInRange(userId, start, end);
  }

  Future<List<TransactionItem>> getCurrentWeek(DateTime weekStart) async {
    final userId = _userId;
    if (userId == null) return [];
    return _repository.fetchTransactionsInWeek(userId, weekStart);
  }

  Future<void> _reload({
    required String userId,
    required int page,
    required bool withLoading,
  }) async {
    if (withLoading) {
      state = state.copyWith(
        isLoading: true,
        page: 0,
        hasMore: true,
        items: [],
      );
    }
    final items = await _repository.fetchTransactionsPaged(
      userId: userId,
      limit: _pageSize,
      offset: page * _pageSize,
    );

    state = state.copyWith(
      items: items,
      isLoading: false,
      hasMore: items.length == _pageSize,
      page: 1,
    );
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionListState>((ref) {
      ref.watch(currentUserIdProvider);
      return TransactionNotifier(
        ref,
        ref.watch(transactionRepositoryProvider),
        ref.watch(syncServiceProvider),
      );
    });
