import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:flutter/foundation.dart';

class RemoteTransactionRepository {
  RemoteTransactionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Future<String> upsertTransaction(String userId, TransactionItem item) async {
    debugPrint(
      'RemoteTransactionRepository: trying Firestore sync for transaction '
      '(userId=$userId, localId=${item.id}, remoteId=${item.remoteId ?? "new"})',
    );
    final data = item
        .copyWith(
          userId: userId,
          updatedAt: DateTime.now(),
          syncStatus: SyncStatus.synced,
        )
        .toJson();
    data.remove('id');

    if (item.remoteId != null && item.remoteId!.isNotEmpty) {
      await _collection(
        userId,
      ).doc(item.remoteId).set(data, SetOptions(merge: true));
      return item.remoteId!;
    }

    final doc = _collection(userId).doc();
    data['remoteId'] = doc.id;
    await doc.set(data, SetOptions(merge: true));
    return doc.id;
  }

  Future<List<TransactionItem>> fetchTransactions(String userId) async {
    debugPrint(
      'RemoteTransactionRepository: fetching transactions from Firestore for userId=$userId',
    );
    final snapshot = await _collection(
      userId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['remoteId'] ??= doc.id;
      data['userId'] ??= userId;
      return TransactionItem.fromJson(data);
    }).toList();
  }
}
