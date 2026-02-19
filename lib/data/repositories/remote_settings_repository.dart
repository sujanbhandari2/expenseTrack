import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_finance_tracker/domain/models/app_settings.dart';
import 'package:daily_finance_tracker/domain/models/sync_status.dart';
import 'package:flutter/foundation.dart';

class RemoteSettingsRepository {
  RemoteSettingsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meta')
        .doc('settings');
  }

  Future<void> upsertSettings(String userId, AppSettings settings) async {
    debugPrint(
      'RemoteSettingsRepository: trying Firestore sync for settings (userId=$userId)',
    );
    final data = settings
        .copyWith(
          userId: userId,
          remoteId: 'settings',
          updatedAt: DateTime.now(),
          syncStatus: SyncStatus.synced,
        )
        .toJson();
    data.remove('id');
    await _doc(userId).set(data, SetOptions(merge: true));
  }

  Future<AppSettings?> fetchSettings(String userId) async {
    debugPrint(
      'RemoteSettingsRepository: fetching settings from Firestore for userId=$userId',
    );
    final snapshot = await _doc(userId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    final data = snapshot.data()!;
    data['remoteId'] = 'settings';
    data['userId'] = userId;
    return AppSettings.fromJson(data);
  }
}
