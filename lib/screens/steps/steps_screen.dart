import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/permission_service.dart';
import '../../services/step_service.dart';

import 'journey_progress_card.dart';
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

  StreamSubscription<int>? _subscription;

  int _steps = 0;

  bool _loading = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
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

   _subscription = _stepService.stepStream.listen((value) {
    if (!mounted) return;

    setState(() {
      _steps = value;
    });
   });

   setState(() => _loading = false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_permissionGranted) {
      return const PermissionView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      body: SafeArea(
        child: SingleChildScrollView(
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
              ),

              const SizedBox(height: 20),

              JourneyProgressCard(
                destination: "Golden Temple",
                totalDistanceKm: 465,
                steps: _steps,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}