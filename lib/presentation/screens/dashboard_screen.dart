import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:daily_finance_tracker/core/utils/formatters.dart';
import 'package:daily_finance_tracker/domain/models/dashboard_filter.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/providers/auth_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/dashboard_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/settings_provider.dart';
import 'package:daily_finance_tracker/presentation/widgets/empty_state.dart';
import 'package:daily_finance_tracker/presentation/widgets/kpi_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _chartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardStatsProvider);
    final filter = ref.watch(dashboardFilterProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final user = ref.watch(authStateProvider).valueOrNull;
    final currency = settings?.currency ?? 'NPR';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: dashboardAsync.when(
        data: (bundle) {
          final stats = bundle.stats;
          final isWarn = stats.weeklyBudgetUsed >= 80;
          final isAlert = stats.weeklyBudgetUsed >= 100;

          final transactions = [...bundle.transactions]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final upcoming = transactions
              .where((e) => e.type == TransactionType.expense)
              .take(5)
              .toList();
          final recent = transactions.take(6).toList();

          final displayName = user?.displayName?.trim();
          final greetingName = (displayName == null || displayName.isEmpty)
              ? 'there'
              : displayName;

          return Container(
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
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(dashboardStatsProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello,',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                greetingName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        const _ActionBubble(icon: Icons.search_rounded),
                        const SizedBox(width: 8),
                        _ActionBubble(
                          icon: Icons.notifications_none_rounded,
                          onTap: () => ref.invalidate(dashboardStatsProvider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BalanceHeroCard(
                      currency: currency,
                      balance: stats.balance,
                      income: stats.totalIncome,
                      expense: stats.totalExpense,
                      onAddTap: () => context.go('/management'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: DashboardFilter.values.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final item = DashboardFilter.values[index];
                          final selected = filter == item;
                          return ChoiceChip(
                            label: Text(item.label),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) =>
                                ref
                                        .read(dashboardFilterProvider.notifier)
                                        .state =
                                    item,
                            labelStyle: TextStyle(
                              color: selected
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SectionHeader(
                      title: 'Upcoming payment',
                      trailing: 'See all',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 172,
                      child: upcoming.isEmpty
                          ? const EmptyState(
                              message:
                                  'No upcoming expense payments right now.',
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: upcoming.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                return _UpcomingPaymentCard(
                                  transaction: upcoming[index],
                                  currency: currency,
                                  highlighted: index == 0,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 10),
                    _SectionHeader(
                      title: 'Recent transactions',
                      trailing: 'See all',
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: recent.isEmpty
                            ? const EmptyState(
                                message: 'No transactions for this filter yet.',
                              )
                            : Column(
                                children: [
                                  for (var i = 0; i < recent.length; i++) ...[
                                    _RecentTransactionRow(
                                      transaction: recent[i],
                                      currency: currency,
                                    ),
                                    if (i != recent.length - 1)
                                      Divider(
                                        height: 14,
                                        color: scheme.outlineVariant,
                                      ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: isAlert
                          ? scheme.errorContainer
                          : isWarn
                          ? scheme.secondaryContainer
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bundle.budgetMessage,
                              style: TextStyle(
                                color: isAlert
                                    ? scheme.onErrorContainer
                                    : isWarn
                                    ? scheme.onSecondaryContainer
                                    : scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (stats.weeklyBudgetUsed / 100).clamp(
                                  0,
                                  1,
                                ),
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Spent ${formatCurrency(stats.weekSpent, currency)} • Remaining ${formatCurrency(stats.weekRemaining, currency)}',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.65,
                      children: [
                        KpiCard(
                          title: 'Savings Rate',
                          value: '${stats.savingsRate.toStringAsFixed(1)}%',
                        ),
                        KpiCard(
                          title: 'Transactions',
                          value: '${stats.transactionCount}',
                        ),
                        KpiCard(
                          title: 'Expense Ratio',
                          value:
                              '${stats.expenseToIncomeRatio.toStringAsFixed(1)}%',
                        ),
                        KpiCard(
                          title: 'Avg Daily Expense',
                          value: formatCurrency(
                            stats.averageDailyExpense,
                            currency,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetricPill(
                          title: 'Highest category',
                          value: stats.highestCategory,
                        ),
                        _MetricPill(
                          title: 'Expense growth',
                          value: '${stats.expenseGrowth.toStringAsFixed(1)}%',
                        ),
                        _MetricPill(
                          title: 'Range',
                          value:
                              '${formatDate(bundle.rangeStart)} - ${formatDate(bundle.rangeEnd.subtract(const Duration(days: 1)))}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RepaintBoundary(
                      key: _chartKey,
                      child: Column(
                        children: [
                          Card(
                            child: SizedBox(
                              height: 210,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: _ExpenseLineChart(
                                  points: bundle.dailyExpensePoints,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: SizedBox(
                              height: 220,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: _CategoryPieChart(
                                  map: bundle.categoryBreakdown,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _exportPdf(bundle),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export PDF'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => _exportExcel(bundle),
                            icon: const Icon(Icons.table_chart),
                            label: const Text('Export Excel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load dashboard: $e')),
      ),
    );
  }

  Future<void> _exportPdf(DashboardBundle bundle) async {
    final image = await _captureChart();
    final path = await ref
        .read(exportServiceProvider)
        .exportPdfReport(
          start: bundle.rangeStart,
          end: bundle.rangeEnd,
          stats: bundle.stats,
          categoryBreakdown: bundle.categoryBreakdown,
          transactions: bundle.transactions,
          chartImage: image,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF exported: $path')));
  }

  Future<void> _exportExcel(DashboardBundle bundle) async {
    final path = await ref
        .read(exportServiceProvider)
        .exportExcelReport(transactions: bundle.transactions);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Excel exported: $path')));
  }

  Future<Uint8List?> _captureChart() async {
    final boundary =
        _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class _ActionBubble extends StatelessWidget {
  const _ActionBubble({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          shape: BoxShape.circle,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: .8),
          ),
        ),
        child: Icon(icon, color: scheme.onSurface),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _BalanceHeroCard extends StatelessWidget {
  const _BalanceHeroCard({
    required this.currency,
    required this.balance,
    required this.income,
    required this.expense,
    required this.onAddTap,
  });

  final String currency;
  final double balance;
  final double income;
  final double expense;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFEDE9FF), Color(0xFFC9C0FF)],
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton.filled(
                  onPressed: onAddTap,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              formatCurrency(balance, currency),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniPill(
                  label: 'Income',
                  value: formatCurrency(income, currency),
                  positive: true,
                ),
                const SizedBox(width: 8),
                _MiniPill(
                  label: 'Expense',
                  value: formatCurrency(expense, currency),
                  positive: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.value,
    required this.positive,
  });

  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final accent = positive ? const Color(0xFF1B9C5A) : const Color(0xFFE45858);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .75),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingPaymentCard extends StatelessWidget {
  const _UpcomingPaymentCard({
    required this.transaction,
    required this.currency,
    required this.highlighted,
  });

  final TransactionItem transaction;
  final String currency;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final soft = highlighted
        ? Colors.white.withValues(alpha: .82)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: 186,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: highlighted
            ? const LinearGradient(
                colors: [Color(0xFF7F4DF5), Color(0xFF5D2CF3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white,
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: .38),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: highlighted
            ? null
            : Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: .6),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: highlighted
                ? Colors.white.withValues(alpha: .9)
                : Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.payments_outlined,
              color: highlighted
                  ? const Color(0xFF5D2CF3)
                  : Theme.of(context).colorScheme.onPrimaryContainer,
              size: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            transaction.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${formatCurrency(transaction.amount, currency)}/month',
            style: TextStyle(color: fg, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '${transaction.category} • ${formatDate(transaction.createdAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: soft,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionRow extends StatelessWidget {
  const _RecentTransactionRow({
    required this.transaction,
    required this.currency,
  });

  final TransactionItem transaction;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF1B9C5A) : const Color(0xFFE45858);

    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatDate(transaction.createdAt)}, ${formatTime(transaction.createdAt)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount, currency)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .75)),
      ),
      child: Text(
        '$title: $value',
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExpenseLineChart extends StatelessWidget {
  const _ExpenseLineChart({required this.points});

  final List<MapEntry<DateTime, double>> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const EmptyState(
        message: 'No expense trend data for selected filter.',
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].value));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0x1A5A6175)),
          getDrawingVerticalLine: (_) => const FlLine(color: Color(0x145A6175)),
        ),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF6C52FF), Color(0xFF9A8DFF)],
            ),
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C52FF).withValues(alpha: .25),
                  const Color(0xFF9A8DFF).withValues(alpha: .05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart({required this.map});

  final Map<String, double> map;

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) {
      return const EmptyState(message: 'No category data for selected filter.');
    }

    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    const palette = [
      Color(0xFF7A4CFF),
      Color(0xFFA58AFF),
      Color(0xFF205E9F),
      Color(0xFF081E6A),
      Color(0xFF5AC8FA),
      Color(0xFF7DD3FC),
    ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 38,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    title:
                        '${((entries[i].value / total) * 100).toStringAsFixed(0)}%',
                    radius: 54,
                    color: palette[i % palette.length],
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${e.key}: ${e.value.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
