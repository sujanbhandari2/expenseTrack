import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:daily_finance_tracker/core/utils/formatters.dart';
import 'package:daily_finance_tracker/domain/models/dashboard_filter.dart';
import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/providers/dashboard_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/settings_provider.dart';
import 'package:daily_finance_tracker/presentation/widgets/empty_state.dart';
import 'package:daily_finance_tracker/presentation/widgets/kpi_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final currency = settings?.currency ?? 'NPR';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(dashboardStatsProvider),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (bundle) {
          final stats = bundle.stats;
          final isWarn = stats.weeklyBudgetUsed >= 80;
          final isAlert = stats.weeklyBudgetUsed >= 100;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.primaryContainer.withValues(alpha: .22),
                  scheme.surface,
                  scheme.surface,
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
              children: [
                _BalanceHeroCard(
                  currency: currency,
                  balance: stats.balance,
                  income: stats.totalIncome,
                  expense: stats.totalExpense,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: DashboardFilter.values.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = DashboardFilter.values[index];
                      final selected = filter == item;
                      return ChoiceChip(
                        label: Text(item.label),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) =>
                            ref.read(dashboardFilterProvider.notifier).state =
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
                Text(
                  'Range: ${formatDate(bundle.rangeStart)} - ${formatDate(bundle.rangeEnd.subtract(const Duration(days: 1)))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Card(
                  color: isAlert
                      ? scheme.errorContainer
                      : isWarn
                      ? scheme.secondaryContainer
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
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
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (stats.weeklyBudgetUsed / 100).clamp(0, 1),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Spent: ${formatCurrency(stats.weekSpent, currency)} | Remaining: ${formatCurrency(stats.weekRemaining, currency)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    KpiCard(
                      title: 'Total Income',
                      value: formatCurrency(stats.totalIncome, currency),
                      valueColor: const Color(0xFF1B9C5A),
                    ),
                    KpiCard(
                      title: 'Total Expense',
                      value: formatCurrency(stats.totalExpense, currency),
                      valueColor: const Color(0xFFE45858),
                    ),
                    KpiCard(
                      title: 'Remaining Balance',
                      value: formatCurrency(stats.balance, currency),
                    ),
                    KpiCard(
                      title: 'Savings Rate %',
                      value: '${stats.savingsRate.toStringAsFixed(1)}%',
                    ),
                    KpiCard(
                      title: 'Weekly Budget Used %',
                      value: '${stats.weeklyBudgetUsed.toStringAsFixed(1)}%',
                    ),
                    KpiCard(
                      title: 'Average Daily Expense',
                      value: formatCurrency(
                        stats.averageDailyExpense,
                        currency,
                      ),
                    ),
                    KpiCard(
                      title: 'Highest Category Expense',
                      value: stats.highestCategory,
                    ),
                    KpiCard(
                      title: 'Expense vs Previous %',
                      value: '${stats.expenseGrowth.toStringAsFixed(1)}%',
                    ),
                    KpiCard(
                      title: 'Transactions Count',
                      value: '${stats.transactionCount}',
                    ),
                    KpiCard(
                      title: 'Expense-to-Income %',
                      value:
                          '${stats.expenseToIncomeRatio.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RepaintBoundary(
                  key: _chartKey,
                  child: Column(
                    children: [
                      Card(
                        child: SizedBox(
                          height: 240,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _ExpenseLineChart(
                              points: bundle.dailyExpensePoints,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: SizedBox(
                          height: 240,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _CategoryPieChart(
                              map: bundle.categoryBreakdown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _exportPdf(bundle),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                      ),
                    ),
                    const SizedBox(width: 10),
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

class _BalanceHeroCard extends StatelessWidget {
  const _BalanceHeroCard({
    required this.currency,
    required this.balance,
    required this.income,
    required this.expense,
  });

  final String currency;
  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF5C6CF2), Color(0xFF5A9DFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: .85),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formatCurrency(balance, currency),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _MiniPill(
                  label: 'Income',
                  value: formatCurrency(income, currency),
                ),
                const SizedBox(width: 8),
                _MiniPill(
                  label: 'Expense',
                  value: formatCurrency(expense, currency),
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
  const _MiniPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
              colors: [Color(0xFF5C6CF2), Color(0xFF5A9DFE)],
            ),
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5C6CF2).withValues(alpha: .25),
                  const Color(0xFF5A9DFE).withValues(alpha: .05),
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

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 34,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    title:
                        '${((entries[i].value / total) * 100).toStringAsFixed(0)}%',
                    radius: 58,
                    color: Colors.primaries[i % Colors.primaries.length],
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
        const SizedBox(width: 12),
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${e.key}: ${e.value.toStringAsFixed(0)}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
