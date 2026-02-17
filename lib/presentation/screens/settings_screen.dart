import 'package:daily_finance_tracker/presentation/providers/app_providers.dart';
import 'package:daily_finance_tracker/presentation/providers/goal_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/settings_provider.dart';
import 'package:daily_finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final goalAsync = ref.watch(goalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            settingsAsync.when(
              data: (settings) {
                final timeParts = settings.reminderTime.split(':');
                final time = TimeOfDay(
                  hour: int.parse(timeParts.first),
                  minute: int.parse(timeParts.last),
                );

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          icon: Icons.notifications_active_outlined,
                          title: 'Daily Reminder',
                        ),
                        const SizedBox(height: 6),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enable daily reminder'),
                          value: settings.dailyReminderEnabled,
                          onChanged: (v) async {
                            final message = await ref
                                .read(settingsProvider.notifier)
                                .updateReminder(
                                  enabled: v,
                                  time: settings.reminderTime,
                                );
                            if (!context.mounted || message == null) return;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Reminder time: ${time.format(context)}'),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (picked != null) {
                              final formatted =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              final message = await ref
                                  .read(settingsProvider.notifier)
                                  .updateReminder(
                                    enabled: settings.dailyReminderEnabled,
                                    time: formatted,
                                  );
                              if (!context.mounted || message == null) return;
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          },
                        ),
                        const Divider(),
                        DropdownButtonFormField<String>(
                          initialValue: settings.currency,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'NPR', child: Text('NPR')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                            DropdownMenuItem(value: 'INR', child: Text('INR')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateCurrency(v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.wallet_outlined,
                      title: 'Weekly Budget Goal',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Weekly budget limit',
                        hintText: 'e.g. 15000',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final value = double.tryParse(
                            _budgetController.text.trim(),
                          );
                          if (value == null || value <= 0) return;
                          await ref
                              .read(goalProvider.notifier)
                              .saveWeeklyBudget(value);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Weekly budget saved.'),
                            ),
                          );
                        },
                        child: const Text('Save Goal'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    goalAsync.when(
                      data: (goal) => Text(
                        goal == null
                            ? 'No active goal set.'
                            : 'Current goal: ${goal.weeklyBudget.toStringAsFixed(2)} (from ${goal.startDate.year}-${goal.startDate.month}-${goal.startDate.day})',
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.science_outlined,
                      title: 'Debug Tools',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () async {
                          await ref
                              .read(dummyDataServiceProvider)
                              .insertDummyData(days: 45);
                          await ref
                              .read(transactionProvider.notifier)
                              .loadInitial();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dummy data inserted.'),
                            ),
                          );
                        },
                        child: const Text('Insert Dummy Transactions'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
