import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _keyCompleted = 'hasCompletedOnboarding';

  /// Returns true if onboarding is completed.
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompleted) ?? false;
  }

  /// Marks onboarding as completed.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompleted, true);
  }

  /// (Optional) For testing only.
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompleted);
  }
}