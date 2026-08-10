import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_sync_service.dart';

/// Tracks whether the user has "recited"/reaffirmed their Sankalp (the
/// manifestation wish attached to a Yatra) today. This turns the Sankalp
/// from a one-time note into a small daily ritual on the Home dashboard.
/// Syncs check-ins to cloud for multi-device support.
class SankalpService {
  static const _prefix = 'sankalp_checkin_';

  static String _todayKey(String journeyId) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return '$_prefix${journeyId}_$today';
  }

  static String _todayDate() =>
      DateTime.now().toIso8601String().substring(0, 10);

  static Future<bool> isCheckedInToday(String journeyId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_todayKey(journeyId)) ?? false;
  }

  static Future<void> checkInToday(String journeyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_todayKey(journeyId), true);

    // Sync to cloud in background (fire-and-forget)
    final today = _todayDate();
    CloudSyncService().syncSankalpCheckIn(
      journeyId: journeyId,
      date: today,
      checkedIn: true,
    );
  }
}
