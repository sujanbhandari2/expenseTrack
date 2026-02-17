import 'package:daily_finance_tracker/core/constants/categories.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:flutter/material.dart';

class TransactionFormSheet extends StatefulWidget {
  const TransactionFormSheet({super.key, this.initial});

  final TransactionItem? initial;

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _amountController = TextEditingController(
      text: initial != null ? initial.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
    _type = initial?.type ?? TransactionType.expense;
    _selectedDate = initial?.createdAt ?? DateTime.now();
    _selectedCategory = initial?.category ?? expenseCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.expense ? expenseCategories : incomeCategories;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.initial == null ? 'Add Transaction' : 'Edit Transaction'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) {
                  final parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                  ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ],
                selected: {_type},
                onSelectionChanged: (selected) {
                  setState(() {
                    _type = selected.first;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (Optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        _selectedDate.hour,
                        _selectedDate.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final result = TransactionItem(
      id: widget.initial?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      type: _type,
      category: _selectedCategory,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      createdAt: _selectedDate,
    );

    Navigator.of(context).pop(result);
  }
}
