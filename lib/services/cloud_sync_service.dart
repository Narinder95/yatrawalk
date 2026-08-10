import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Centralized service for syncing local data to Firebase Firestore.
///
/// This follows a "local-first" pattern: all operations complete locally,
/// and cloud sync happens in the background without blocking the user.
/// Network failures are logged but never thrown.
class CloudSyncService {
  CloudSyncService._internal();
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Syncs user profile to cloud. Fire-and-forget - errors logged but not thrown.
  Future<void> syncUserProfile({
    required String name,
    required int dailyGoal,
    required int? age,
    required double? heightCm,
    required double? weightKg,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'name': name,
          'dailyGoal': dailyGoal,
          'age': age,
          'heightCm': heightCm,
          'weightKg': weightKg,
          'profileSetupCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[CloudSync] Profile synced for $uid');
    } catch (e) {
      debugPrint('[CloudSync] Profile sync failed: $e');
    }
  }

  /// Syncs onboarding completion status to cloud.
  Future<void> syncOnboardingComplete() async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'onboardingCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[CloudSync] Onboarding marked complete for $uid');
    } catch (e) {
      debugPrint('[CloudSync] Onboarding sync failed: $e');
    }
  }

  /// Syncs a day's step count to cloud step history.
  Future<void> syncDailySteps({
    required String date, // YYYY-MM-DD format
    required int steps,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('step_history')
          .doc(date)
          .set(
        {
          'date': date,
          'steps': steps,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[CloudSync] Steps synced for $date: $steps');
    } catch (e) {
      debugPrint('[CloudSync] Step sync failed for $date: $e');
    }
  }

  /// Syncs a Yatra journey to cloud.
  Future<void> syncJourney({
    required String journeyId,
    required String startLocation,
    required String destinationName,
    required String destinationLocation,
    required String destinationEmoji,
    required double latitude,
    required double longitude,
    required double totalDistanceKm,
    required double completedDistanceKm,
    required DateTime startDate,
    required int startStepsSnapshot,
    required String sankalp,
    required bool completed,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('journeys')
          .doc(journeyId)
          .set(
        {
          'id': journeyId,
          'startLocation': startLocation,
          'destinationName': destinationName,
          'destinationLocation': destinationLocation,
          'destinationEmoji': destinationEmoji,
          'latitude': latitude,
          'longitude': longitude,
          'totalDistanceKm': totalDistanceKm,
          'completedDistanceKm': completedDistanceKm,
          'startDate': startDate.toIso8601String(),
          'startStepsSnapshot': startStepsSnapshot,
          'sankalp': sankalp,
          'completed': completed,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[CloudSync] Journey synced: $journeyId');
    } catch (e) {
      debugPrint('[CloudSync] Journey sync failed: $e');
    }
  }

  /// Syncs a Sankalp check-in for a specific date.
  Future<void> syncSankalpCheckIn({
    required String journeyId,
    required String date, // YYYY-MM-DD format
    required bool checkedIn,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      final docId = '${journeyId}_$date';
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('sankalp_checkins')
          .doc(docId)
          .set(
        {
          'journeyId': journeyId,
          'date': date,
          'checkedIn': checkedIn,
          'timestamp': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[CloudSync] Sankalp check-in synced: $journeyId on $date');
    } catch (e) {
      debugPrint('[CloudSync] Sankalp check-in sync failed: $e');
    }
  }

  /// Syncs a mantra recitation for a specific date.
  Future<void> syncMantraRecitation({
    required String mantraId,
    required String date, // YYYY-MM-DD format
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      final docId = '${mantraId}_$date';
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('mantra_recitations')
          .doc(docId)
          .set(
        {
          'mantraId': mantraId,
          'date': date,
          'recitedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[CloudSync] Mantra recitation synced: $mantraId on $date');
    } catch (e) {
      debugPrint('[CloudSync] Mantra recitation sync failed: $e');
    }
  }

  /// Retrieves user's onboarding status from cloud. Used on app startup
  /// to determine if user should see onboarding screen on a new device.
  Future<bool> hasCompletedOnboardingOnCloud() async {
    final uid = _currentUserId;
    if (uid == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['onboardingCompleted'] ?? false;
    } catch (e) {
      debugPrint('[CloudSync] Failed to fetch onboarding status: $e');
      return false;
    }
  }

  /// Retrieves user's profile setup status from cloud. Used on app startup.
  Future<bool> hasCompletedProfileSetupOnCloud() async {
    final uid = _currentUserId;
    if (uid == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['profileSetupCompleted'] ?? false;
    } catch (e) {
      debugPrint('[CloudSync] Failed to fetch profile setup status: $e');
      return false;
    }
  }

  /// Fetches all journeys for the current user from cloud.
  /// Used to sync multi-device journey data.
  Future<List<Map<String, dynamic>>> fetchJourneysFromCloud() async {
    final uid = _currentUserId;
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('journeys')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('[CloudSync] Failed to fetch journeys from cloud: $e');
      return [];
    }
  }

  /// Fetches step history from cloud for a user.
  /// Useful for syncing steps across devices.
  Future<Map<String, int>> fetchStepHistoryFromCloud() async {
    final uid = _currentUserId;
    if (uid == null) return {};

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('step_history')
          .get();

      final history = <String, int>{};
      for (final doc in snapshot.docs) {
        final steps = doc.data()['steps'] as int?;
        if (steps != null) {
          history[doc.id] = steps;
        }
      }
      return history;
    } catch (e) {
      debugPrint('[CloudSync] Failed to fetch step history from cloud: $e');
      return {};
    }
  }
}
