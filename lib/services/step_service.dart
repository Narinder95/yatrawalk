import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepService {
  StepService._internal();

  static final StepService _instance = StepService._internal();

  factory StepService() => _instance;

  StreamSubscription<StepCount>? _stepSubscription;

  final StreamController<int> _controller =
      StreamController<int>.broadcast();

  Stream<int> get stepStream => _controller.stream;

  int _currentSteps = 0;
  int _todaySteps = 0;
  int _initialSensorSteps = -1;

  bool _started = false;

  int get currentSteps => _currentSteps;

  int get todaySteps => _todaySteps;

  Future<void> start() async {
    if (_started) return;

    final permission = await Permission.activityRecognition.request();

    if (!permission.isGranted) {
      print("Activity Recognition permission denied");
      return;
    }

    await _loadSavedData();

    print("Listening for step events...");

    _stepSubscription = Pedometer.stepCountStream.listen(
   (event) {
    print("RAW STEP EVENT: ${event.steps}");
    _onStepCount(event);
   },
   onError: (e) {
    print("PEDOMETER ERROR: $e");
  },
 );

    _started = true;

    print("Step service started");
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();

    final today =
        DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString("step_date");

    if (savedDate != today) {
      await prefs.setString("step_date", today);
      await prefs.setInt(
        "initial_sensor_steps",
        event.steps,
      );

      _initialSensorSteps = event.steps;
    }

    _initialSensorSteps =
        prefs.getInt("initial_sensor_steps") ??
            event.steps;

    _currentSteps = event.steps;
    _todaySteps = event.steps;

    _controller.add(_todaySteps);

    print("TODAY = $_todaySteps");

    if (_todaySteps < 0) {
      _todaySteps = 0;
    }

    await prefs.setInt(
      "today_steps",
      _todaySteps,
    );

    print("Raw Steps : ${event.steps}");
    print("Today Steps : $_todaySteps");

    _controller.add(_todaySteps);
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    _todaySteps =
        prefs.getInt("today_steps") ?? 0;

    _initialSensorSteps =
        prefs.getInt("initial_sensor_steps") ?? -1;

    _controller.add(_todaySteps);
  }

  Future<void> resetToday() async {
    final prefs = await SharedPreferences.getInstance();

    _initialSensorSteps = _currentSteps;
    _todaySteps = 0;

    await prefs.setInt(
      "initial_sensor_steps",
      _initialSensorSteps,
    );

    await prefs.setInt(
      "today_steps",
      0,
    );

    _controller.add(0);
  }

  Future<void> stop() async {
    await _stepSubscription?.cancel();
    _started = false;
  }

  void dispose() {
    _stepSubscription?.cancel();
    _controller.close();
  }
}