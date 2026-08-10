import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'cloud_sync_service.dart';

/// Single source of truth for the user's profile (name, age, height,
/// weight, daily step goal). Everything reads/writes through here so the
/// Profile screen, Home dashboard and Steps screen can never disagree
/// about the daily goal again.
class UserProfileService {
  UserProfileService._internal();
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;

  static const _key = 'user_profile';
  static const _profileSetupKey = 'hasCompletedProfileSetup';

  final _dailyGoalController = StreamController<int>.broadcast();

  /// Emits whenever the daily step goal is saved, so screens that are kept
  /// alive (e.g. Home/Steps tabs inside an IndexedStack, which never see a
  /// Navigator pop) can stay in sync with changes made on the Profile screen.
  Stream<int> get dailyGoalStream => _dailyGoalController.stream;

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return const UserProfile(name: '');
    }
    try {
      return UserProfile.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
    } catch (_) {
      return const UserProfile(name: '');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
    _dailyGoalController.add(profile.dailyGoal);

    // Sync to cloud in background (fire-and-forget)
    CloudSyncService().syncUserProfile(
      name: profile.name,
      dailyGoal: profile.dailyGoal,
      age: profile.age,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
    );
  }

  Future<int> getDailyGoal() async {
    final profile = await loadProfile();
    return profile.dailyGoal;
  }

  Future<bool> hasCompletedProfileSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileSetupKey) ?? false;
  }

  Future<void> markProfileSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileSetupKey, true);
  }

  /// Clears the "profile setup done" flag only - used when a different
  /// account signs in on this device so they get asked for their own name.
  Future<void> resetForNewAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileSetupKey);
    await prefs.remove(_key);
  }
}
