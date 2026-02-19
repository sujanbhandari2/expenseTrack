import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_item.freezed.dart';
part 'transaction_item.g.dart';

enum TransactionType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
}

@freezed
class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    int? id,
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    String? note,
    required DateTime createdAt,
    @Default('') String userId,
    String? remoteId,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
  }) = _TransactionItem;

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
}
