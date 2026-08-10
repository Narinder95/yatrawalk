import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Only import pedometer on mobile platforms
import 'package:pedometer/pedometer.dart';

import 'cloud_sync_service.dart';

class StepService {
  StepService._internal();

  static final StepService _instance = StepService._internal();

  factory StepService() => _instance;

  StreamSubscription<StepCount>? _stepSubscription;

  final StreamController<int> _controller =
      StreamController<int>.broadcast();

  // Emits the all-time (lifetime) step total, i.e. every step ever recorded
  // by the app, including today's steps so far. This powers "Total Yatra
  // Steps" on the home dashboard.
  final StreamController<int> _totalController =
      StreamController<int>.broadcast();

  Stream<int> get stepStream => _controller.stream;

  Stream<int> get totalStepStream => _totalController.stream;

  int _currentSteps = 0;
  int _todaySteps = 0;
  int _initialSensorSteps = -1;

  // Steps accumulated on days prior to today.
  int _totalStepsBeforeToday = 0;

  bool _started = false;

  int get currentSteps => _currentSteps;

  int get todaySteps => _todaySteps;

  // All-time steps = everything banked from previous days + today so far.
  int get totalSteps => _totalStepsBeforeToday + _todaySteps;

  Future<void> start() async {
    if (_started) return;

    // Skip pedometer on web - not supported
    if (kIsWeb) {
      await _loadSavedData();
      _started = true;
      return;
    }

    final permission = await Permission.activityRecognition.request();

    if (!permission.isGranted) {
      return;
    }

    await _loadSavedData();

    _stepSubscription = Pedometer.stepCountStream.listen(
      (event) {
        _onStepCount(event);
      },
      onError: (e) {
        debugPrint('Pedometer error: $e');
      },
    );

    _started = true;
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString("step_date");

    if (savedDate != null && savedDate != today) {
      // A new day has started - bank yesterday's total into all-time steps
      // before resetting today's counter.
      final priorTodaySteps = prefs.getInt("today_steps") ?? 0;
      _totalStepsBeforeToday += priorTodaySteps;

      await prefs.setInt("total_steps_before_today", _totalStepsBeforeToday);
    }

    if (savedDate != today) {
      await prefs.setString("step_date", today);
      await prefs.setInt("initial_sensor_steps", event.steps);
      await prefs.setInt("today_steps", 0);

      _initialSensorSteps = event.steps;
      _todaySteps = 0;
    }

    _initialSensorSteps = prefs.getInt("initial_sensor_steps") ?? event.steps;

    _currentSteps = event.steps;
    _todaySteps = event.steps - _initialSensorSteps;

    if (_todaySteps < 0) {
      _todaySteps = 0;
    }

    await prefs.setInt("today_steps", _todaySteps);
    await _recordDailyHistory(today, _todaySteps);

    _controller.add(_todaySteps);
    _totalController.add(totalSteps);
  }

  static const _historyKey = "daily_step_history";

  /// Persists today's step count into a date->steps history map, so we
  /// can compute a walking streak later. Keeps the last 90 days.
  /// Also syncs to cloud for multi-device support.
  Future<void> _recordDailyHistory(String date, int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    final Map<String, dynamic> history =
        raw != null ? Map<String, dynamic>.from(jsonDecode(raw)) : {};

    history[date] = steps;

    if (history.length > 90) {
      final sortedKeys = history.keys.toList()..sort();
      for (final k in sortedKeys.take(history.length - 90)) {
        history.remove(k);
      }
    }

    await prefs.setString(_historyKey, jsonEncode(history));

    // Sync to cloud in background (fire-and-forget)
    CloudSyncService().syncDailySteps(date: date, steps: steps);
  }

  /// Number of consecutive days (ending today) with at least one recorded
  /// step. Used for the "streak" shown on the Home dashboard.
  Future<int> getStreakDays() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    final Map<String, dynamic> history =
        raw != null ? Map<String, dynamic>.from(jsonDecode(raw)) : {};

    int streak = 0;
    DateTime day = DateTime.now();

    // Today counts if it already has steps recorded; otherwise start
    // checking from yesterday so an untouched morning doesn't zero out
    // yesterday's completed streak.
    final todayKey = day.toIso8601String().substring(0, 10);
    if ((history[todayKey] ?? 0) <= 0) {
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      final key = day.toIso8601String().substring(0, 10);
      final steps = (history[key] ?? 0) as num;
      if (steps > 0) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    _todaySteps = prefs.getInt("today_steps") ?? 0;

    _initialSensorSteps = prefs.getInt("initial_sensor_steps") ?? -1;

    _totalStepsBeforeToday = prefs.getInt("total_steps_before_today") ?? 0;

    _controller.add(_todaySteps);
    _totalController.add(totalSteps);
  }

  Future<void> resetToday() async {
    final prefs = await SharedPreferences.getInstance();

    _initialSensorSteps = _currentSteps;
    _todaySteps = 0;

    await prefs.setInt("initial_sensor_steps", _initialSensorSteps);

    await prefs.setInt("today_steps", 0);

    _controller.add(0);
    _totalController.add(totalSteps);
  }

  Future<void> stop() async {
    await _stepSubscription?.cancel();
    _started = false;
  }

  void dispose() {
    _stepSubscription?.cancel();
    _controller.close();
    _totalController.close();
  }
}
