import 'package:daily_finance_tracker/data/repositories/transaction_repository.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
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
  TransactionNotifier(this._repository) : super(const TransactionListState()) {
    loadInitial();
  }

  final TransactionRepository _repository;
  static const _pageSize = 25;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, page: 0, hasMore: true, items: []);
    final items = await _repository.fetchTransactionsPaged(limit: _pageSize, offset: 0);
    state = state.copyWith(
      items: items,
      isLoading: false,
      hasMore: items.length == _pageSize,
      page: 1,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    final offset = state.page * _pageSize;
    final next = await _repository.fetchTransactionsPaged(limit: _pageSize, offset: offset);

    state = state.copyWith(
      isLoading: false,
      items: [...state.items, ...next],
      hasMore: next.length == _pageSize,
      page: state.page + 1,
    );
  }

  Future<void> addTransaction(TransactionItem item) async {
    await _repository.createTransaction(item);
    await loadInitial();
  }

  Future<void> updateTransaction(TransactionItem item) async {
    await _repository.updateTransaction(item);
    await loadInitial();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
    await loadInitial();
  }

  Future<List<TransactionItem>> getInRange(DateTime start, DateTime end) {
    return _repository.fetchTransactionsInRange(start, end);
  }

  Future<List<TransactionItem>> getCurrentWeek(DateTime weekStart) {
    return _repository.fetchTransactionsInWeek(weekStart);
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionListState>((ref) {
      return TransactionNotifier(ref.watch(transactionRepositoryProvider));
    });
