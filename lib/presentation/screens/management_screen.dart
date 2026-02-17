import 'package:daily_finance_tracker/core/utils/formatters.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:daily_finance_tracker/presentation/providers/settings_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:daily_finance_tracker/presentation/widgets/empty_state.dart';
import 'package:daily_finance_tracker/presentation/widgets/transaction_form_sheet.dart';
import 'package:daily_finance_tracker/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagementScreen extends ConsumerStatefulWidget {
  const ManagementScreen({super.key});

  @override
  ConsumerState<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends ConsumerState<ManagementScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(transactionProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currency = settings?.currency ?? 'NPR';

    final income = txState.items
        .where((e) => e.type == TransactionType.income)
        .fold<double>(0, (s, e) => s + e.amount);
    final expense = txState.items
        .where((e) => e.type == TransactionType.expense)
        .fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: .16),
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: txState.items.isEmpty && !txState.isLoading
            ? const EmptyState(
                message: 'No transactions yet. Add your first one.',
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(transactionProvider.notifier).loadInitial(),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 90),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryItem(
                                label: 'Income',
                                value: formatCurrency(income, currency),
                                color: const Color(0xFF1B9C5A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _SummaryItem(
                                label: 'Expense',
                                value: formatCurrency(expense, currency),
                                color: const Color(0xFFE45858),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _SummaryItem(
                                label: 'Count',
                                value: '${txState.items.length}',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ..._buildGrouped(txState.items, currency),
                    if (txState.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildGrouped(List<TransactionItem> items, String currency) {
    final map = <DateTime, List<TransactionItem>>{};
    for (final tx in items) {
      final key = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );
      map.putIfAbsent(key, () => []).add(tx);
    }

    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));

    final widgets = <Widget>[];
    for (final key in keys) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Text(
            formatDate(key),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      );

      for (final tx in map[key]!) {
        widgets.add(
          TransactionTile(
            item: tx,
            currency: currency,
            onEdit: () => _editTransaction(tx),
            onDelete: () => _deleteTransaction(tx),
          ),
        );
      }
    }

    return widgets;
  }

  Future<void> _addTransaction() async {
    final result = await showModalBottomSheet<TransactionItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const TransactionFormSheet(),
    );

    if (result != null) {
      await ref.read(transactionProvider.notifier).addTransaction(result);
    }
  }

  Future<void> _editTransaction(TransactionItem item) async {
    final result = await showModalBottomSheet<TransactionItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TransactionFormSheet(initial: item),
    );

    if (result != null) {
      await ref.read(transactionProvider.notifier).updateTransaction(result);
    }
  }

  Future<void> _deleteTransaction(TransactionItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && item.id != null) {
      await ref.read(transactionProvider.notifier).deleteTransaction(item.id!);
    }
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
