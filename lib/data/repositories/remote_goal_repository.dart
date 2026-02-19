import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_finance_tracker/domain/models/budget_goal.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:flutter/foundation.dart';

class RemoteGoalRepository {
  RemoteGoalRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meta')
        .doc('goal');
  }

  Future<void> upsertGoal(String userId, BudgetGoal goal) async {
    debugPrint(
      'RemoteGoalRepository: trying Firestore sync for goal (userId=$userId)',
    );
    final data = goal
        .copyWith(
          userId: userId,
          remoteId: 'goal',
          updatedAt: DateTime.now(),
          syncStatus: SyncStatus.synced,
        )
        .toJson();
    data.remove('id');
    await _doc(userId).set(data, SetOptions(merge: true));
  }

  Future<BudgetGoal?> fetchGoal(String userId) async {
    debugPrint(
      'RemoteGoalRepository: fetching goal from Firestore for userId=$userId',
    );
    final snapshot = await _doc(userId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    final data = snapshot.data()!;
    data['remoteId'] = 'goal';
    data['userId'] = userId;
    return BudgetGoal.fromJson(data);
  }
}
