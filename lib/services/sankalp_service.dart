import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sankalp_model.dart';
import 'cloud_sync_service.dart';

/// Manages user sankalps and tracks daily check-ins. A sankalp is a personal
/// resolution or intention the user can set and track. Multiple sankalps
/// can be active simultaneously, and each can be marked complete/incomplete.
class SankalpService {
  static const _prefix = 'sankalp_checkin_';
  static const _sankalpPrefix = 'sankalp_';
  static const _activeSankalpKey = 'active_sankalps';

  static String _todayKey(String journeyId) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return '$_prefix${journeyId}_$today';
  }

  static String _todayDate() =>
      DateTime.now().toIso8601String().substring(0, 10);

  // Suggested sankalps (hardcoded)
  static List<Sankalp> getSuggestedSankalps() {
    return [
      Sankalp(
        id: 'suggested_1',
        title: 'Walk with Purpose',
        description: 'Every step I take is a step towards my spiritual goal',
        isComplete: false,
        createdDate: DateTime.now(),
        isActive: false,
        emoji: '🚶',
      ),
      Sankalp(
        id: 'suggested_2',
        title: 'Inner Peace',
        description: 'I carry peace and calm within me on this journey',
        isComplete: false,
        createdDate: DateTime.now(),
        isActive: false,
        emoji: '☮️',
      ),
      Sankalp(
        id: 'suggested_3',
        title: 'Gratitude Practice',
        description: 'I am grateful for this journey and all that it teaches me',
        isComplete: false,
        createdDate: DateTime.now(),
        isActive: false,
        emoji: '🙏',
      ),
      Sankalp(
        id: 'suggested_4',
        title: 'Physical Strength',
        description: 'I build strength and endurance with every step',
        isComplete: false,
        createdDate: DateTime.now(),
        isActive: false,
        emoji: '💪',
      ),
      Sankalp(
        id: 'suggested_5',
        title: 'Self Discovery',
        description: 'Through this Yatra, I discover my true self',
        isComplete: false,
        createdDate: DateTime.now(),
        isActive: false,
        emoji: '🔍',
      ),
      Sankalp(
        id: 'suggested_6',
        title: 'Mindful Living',
        description: 'I walk mindfully, present in each moment',
        isComplete: false,
        createdDate: DateTime.now(),
        isActive: false,
        emoji: '🧘',
      ),
    ];
  }

  // Daily check-in tracking (legacy for journey sankalps)
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

  // User sankalp management
  static Future<List<Sankalp>> getUserSankalps() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final sankalps = <Sankalp>[];

    for (final key in keys) {
      if (key.startsWith(_sankalpPrefix)) {
        try {
          final json = prefs.getString(key);
          if (json != null) {
            final decoded = jsonDecode(json);
            if (decoded is Map) {
              final jsonMap = <String, dynamic>{};
              decoded.forEach((k, v) => jsonMap[k.toString()] = v);
              sankalps.add(Sankalp.fromJson(jsonMap));
            }
          }
        } catch (e) {
          print('Error parsing sankalp from $key: $e');
        }
      }
    }

    sankalps.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return sankalps;
  }

  static Future<void> saveSankalp(Sankalp sankalp) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_sankalpPrefix${sankalp.id}';
    final json = jsonEncode(sankalp.toJson());
    print('Saving sankalp with key: $key');
    print('Data: $json');
    await prefs.setString(key, json);
    print('Sankalp saved');
  }

  static Future<void> deleteSankalp(String sankalpId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_sankalpPrefix$sankalpId');
  }

  static Future<void> toggleSankalpComplete(
    String sankalpId,
    bool isComplete,
  ) async {
    final sankalps = await getUserSankalps();
    final index = sankalps.indexWhere((s) => s.id == sankalpId);

    if (index != -1) {
      final updated = sankalps[index].copyWith(
        isComplete: isComplete,
        completedDate: isComplete ? DateTime.now() : null,
      );
      await saveSankalp(updated);
    }
  }

  static Future<void> toggleSankalpActive(
    String sankalpId,
    bool isActive,
  ) async {
    final sankalps = await getUserSankalps();
    final index = sankalps.indexWhere((s) => s.id == sankalpId);

    if (index != -1) {
      final updated = sankalps[index].copyWith(isActive: isActive);
      await saveSankalp(updated);
    }
  }

  static Future<List<Sankalp>> getActiveSankalps() async {
    final sankalps = await getUserSankalps();
    return sankalps.where((s) => s.isActive).toList();
  }
}
