import 'package:daily_finance_tracker/core/utils/formatters.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:daily_finance_tracker/presentation/providers/settings_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:daily_finance_tracker/presentation/widgets/empty_state.dart';
import 'package:daily_finance_tracker/presentation/widgets/transaction_form_sheet.dart';
import 'package:daily_finance_tracker/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final currency = settings?.currency ?? 'NPR';

    final income = txState.items
        .where((e) => e.type == TransactionType.income)
        .fold<double>(0, (s, e) => s + e.amount);
    final expense = txState.items
        .where((e) => e.type == TransactionType.expense)
        .fold<double>(0, (s, e) => s + e.amount);
    final balance = income - expense;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Activity')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: .16),
              scheme.surface,
              scheme.surface,
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
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEDE9FF), Color(0xFFCFC7FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Current Balance',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Month',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatCurrency(balance, currency),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.45,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Row(
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
                                    color: scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Quick Menu',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 116,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _QuickActionCard(
                            icon: Icons.add_card_rounded,
                            title: 'Add expense',
                            onTap: _addTransaction,
                          ),
                          const SizedBox(width: 8),
                          _QuickActionCard(
                            icon: Icons.tune_rounded,
                            title: 'Set budget',
                            onTap: () => context.go('/settings'),
                          ),
                          const SizedBox(width: 8),
                          _QuickActionCard(
                            icon: Icons.refresh_rounded,
                            title: 'Refresh',
                            onTap: () => ref
                                .read(transactionProvider.notifier)
                                .loadInitial(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Payment History',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
          padding: const EdgeInsets.only(top: 12, bottom: 4),
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
      final message = await ref
          .read(transactionProvider.notifier)
          .addTransaction(result);
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      final message = await ref
          .read(transactionProvider.notifier)
          .updateTransaction(result);
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      final message = await ref
          .read(transactionProvider.notifier)
          .deleteTransaction(item.id!);
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer.withValues(alpha: .45),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: .8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: Icon(icon, color: scheme.primary),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
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
