import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/family_member.dart';
import 'step_service.dart';

/// Firestore data model:
///
/// users/{uid}
///   - name, email, familyId (null until they join/create one)
///
/// families/{familyId}
///   - name, inviteCode, createdBy, createdAt
///
/// families/{familyId}/members/{uid}
///   - name, avatarEmoji, totalSteps, todaySteps, updatedAt
class FamilyService {
  FamilyService._internal();
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<int>? _stepSyncSub;
  String? _syncingFamilyId;

  /// Streams the current user's family id, or null if they haven't
  /// created/joined one yet. Emits again automatically if that changes.
  Stream<String?> watchMyFamilyId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.data()?['familyId'] as String?,
        );
  }

  Future<Map<String, dynamic>?> getFamilyInfo(String familyId) async {
    final doc = await _firestore.collection('families').doc(familyId).get();
    return doc.data();
  }

  Future<String> createFamily(String familyName) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    final inviteCode = _generateInviteCode();
    final familyRef = _firestore.collection('families').doc();

    await familyRef.set({
      'name': familyName.trim().isEmpty ? "Our Family" : familyName.trim(),
      'inviteCode': inviteCode,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _upsertMember(familyRef.id, user);

    await _firestore.collection('users').doc(user.uid).set(
      {'familyId': familyRef.id},
      SetOptions(merge: true),
    );

    return familyRef.id;
  }

  Future<void> joinFamilyByCode(String inviteCode) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    final code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw StateError('Please enter an invite code.');
    }

    final matches = await _firestore
        .collection('families')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (matches.docs.isEmpty) {
      throw StateError('No family found with that invite code.');
    }

    final familyDoc = matches.docs.first;

    await _upsertMember(familyDoc.id, user);

    await _firestore.collection('users').doc(user.uid).set(
      {'familyId': familyDoc.id},
      SetOptions(merge: true),
    );
  }

  Future<void> leaveFamily(String familyId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    stopSyncingSteps();

    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(user.uid)
        .delete();

    await _firestore.collection('users').doc(user.uid).set(
      {'familyId': null},
      SetOptions(merge: true),
    );
  }

  /// Real-time list of everyone in the family, sorted by whoever calls
  /// this - callers typically re-sort by steps for a leaderboard.
  Stream<List<FamilyMember>> watchFamilyMembers(String familyId) {
    final myUid = _auth.currentUser?.uid;

    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FamilyMember(
          id: doc.id,
          name: (data['name'] as String?) ?? 'Family Member',
          avatarEmoji: (data['avatarEmoji'] as String?) ?? '🧑',
          totalSteps: (data['totalSteps'] as num?)?.toInt() ?? 0,
          todaySteps: (data['todaySteps'] as num?)?.toInt() ?? 0,
          isCurrentUser: doc.id == myUid,
        );
      }).toList();
    });
  }

  /// Keeps pushing this device's live step counts up to the shared family
  /// doc for as long as this subscription is active. Safe to call
  /// repeatedly - it no-ops if already syncing the same family.
  /// Call [stopSyncingSteps] when the Family screen is disposed.
  void startSyncingSteps(String familyId) {
    if (_syncingFamilyId == familyId && _stepSyncSub != null) return;

    stopSyncingSteps();
    _syncingFamilyId = familyId;

    final stepService = StepService();

    _pushMyStats(familyId, stepService.totalSteps, stepService.todaySteps);

    _stepSyncSub = stepService.totalStepStream.listen((total) {
      _pushMyStats(familyId, total, stepService.todaySteps);
    });
  }

  void stopSyncingSteps() {
    _stepSyncSub?.cancel();
    _stepSyncSub = null;
    _syncingFamilyId = null;
  }

  Future<void> _pushMyStats(
    String familyId,
    int totalSteps,
    int todaySteps,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(user.uid)
        .set(
      {
        'name': user.displayName ?? 'Family Member',
        'avatarEmoji': '🧑',
        'totalSteps': totalSteps,
        'todaySteps': todaySteps,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _upsertMember(String familyId, User user) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(user.uid)
        .set(
      {
        'name': user.displayName ?? 'Family Member',
        'avatarEmoji': '🧑',
        'totalSteps': StepService().totalSteps,
        'todaySteps': StepService().todaySteps,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  String _generateInviteCode() {
    // Avoids visually-ambiguous characters (0/O, 1/I, etc).
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
