import 'package:intl/intl.dart';

final _dateFormat = DateFormat('MMM d, y');
final _timeFormat = DateFormat('hh:mm a');

String formatDate(DateTime date) => _dateFormat.format(date);

String formatTime(DateTime date) => _timeFormat.format(date);

String formatCurrency(double amount, String currency) {
  final symbol = switch (currency) {
    'USD' => '\$',
    'INR' => '₹',
    _ => 'Rs',
  };
  return '$symbol${amount.toStringAsFixed(2)}';
}
