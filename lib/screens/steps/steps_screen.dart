import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/permission_service.dart';
import '../../services/step_service.dart';
import '../../services/user_profile_service.dart';

import 'permission_view.dart';
import 'stats_card.dart';
import 'step_header.dart';
import 'today_steps_card.dart';
import 'package:permission_handler/permission_handler.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final StepService _stepService = StepService();
  final UserProfileService _profileService = UserProfileService();

  StreamSubscription<int>? _subscription;
  StreamSubscription<int>? _totalSubscription;
  StreamSubscription<int>? _dailyGoalSub;

  int _steps = 0;
  int _dailyGoal = 10000;

  bool _loading = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _loadDailyGoal();

    _dailyGoalSub = _profileService.dailyGoalStream.listen((goal) {
      if (!mounted) return;
      setState(() => _dailyGoal = goal);
    });
  }

  Future<void> _initialize() async {
   // On web, skip permission requests (not supported)
   if (kIsWeb) {
     _permissionGranted = true;
     await _stepService.start();
     _steps = _stepService.todaySteps;

     _subscription = _stepService.stepStream.listen((value) {
       if (!mounted) return;
       setState(() => _steps = value);
     });

     _totalSubscription = _stepService.totalStepStream.listen((value) {
       if (!mounted) return;
     });

     if (mounted) setState(() => _loading = false);
     return;
   }

   final statusBefore = await Permission.activityRecognition.status;
   debugPrint("Permission BEFORE: $statusBefore");

   _permissionGranted =
      await PermissionService.requestActivityPermission();

   final statusAfter = await Permission.activityRecognition.status;
   debugPrint("Permission AFTER: $statusAfter");

   debugPrint("Permission Granted = $_permissionGranted");

   if (!_permissionGranted) {
    setState(() => _loading = false);
    return;
   }

   await _stepService.start();

   _steps = _stepService.todaySteps;
   _totalSteps = _stepService.totalSteps;

   _subscription = _stepService.stepStream.listen((value) {
    if (!mounted) return;

    setState(() {
      _steps = value;
    });
   });

   _totalSubscription = _stepService.totalStepStream.listen((value) {
     if (!mounted) return;
     setState(() => _totalSteps = value);
   });

   setState(() => _loading = false);
  }

  Future<void> _loadDailyGoal() async {
    final goal = await _profileService.getDailyGoal();
    if (!mounted) return;
    setState(() => _dailyGoal = goal);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _totalSubscription?.cancel();
    _dailyGoalSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[StepsScreen] Build: loading=$_loading, permissionGranted=$_permissionGranted, isWeb=$kIsWeb');

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_permissionGranted && !kIsWeb) {
      debugPrint('[StepsScreen] Permission denied, showing PermissionView');
      return const PermissionView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadDailyGoal();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const StepHeader(),

                TodayStepsCard(
                  steps: _steps,
                ),

                const SizedBox(height: 20),

                StatsCard(
                  steps: _steps,
                  dailyGoal: _dailyGoal,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
