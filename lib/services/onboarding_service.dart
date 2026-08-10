import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_sync_service.dart';

class OnboardingService {
  static const String _keyCompleted = 'hasCompletedOnboarding';

  /// Returns true if onboarding is completed locally.
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompleted) ?? false;
  }

  /// Marks onboarding as completed locally and syncs to cloud.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompleted, true);

    // Sync to cloud in background (fire-and-forget)
    CloudSyncService().syncOnboardingComplete();
  }

  /// (Optional) For testing only.
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompleted);
  }
}