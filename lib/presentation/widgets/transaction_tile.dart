import 'package:daily_finance_tracker/core/utils/formatters.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionItem item;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF1B9C5A) : const Color(0xFFE45858);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        minLeadingWidth: 14,
        leading: CircleAvatar(
          radius: 19,
          backgroundColor: color.withValues(alpha: .16),
          child: Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${item.category} • ${formatTime(item.createdAt)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${formatCurrency(item.amount, currency)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
