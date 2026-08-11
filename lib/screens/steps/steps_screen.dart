import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/journey_model.dart';
import '../../services/journey_service.dart';
import '../../services/permission_service.dart';
import '../../services/step_service.dart';
import '../../services/user_profile_service.dart';
import '../../utils/yatra_progress.dart';
import '../destination_screen.dart';

import 'journey_progress_card.dart';
import 'permission_view.dart';
import 'stats_card.dart';
import 'step_header.dart';
import 'today_steps_card.dart';
import 'package:permission_handler/permission_handler.dart';

/// The "Daily" tab. Shows today's steps plus the *same* active-Yatra
/// progress as the Home dashboard - it fetches the real active journey
/// via JourneyService and computes progress with the shared YatraProgress
/// utility, instead of the hardcoded "Golden Temple / 465km" placeholder
/// this screen used to show.
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
  int _totalSteps = 0;
  int _dailyGoal = 10000;

  bool _loading = true;
  bool _permissionGranted = false;

  JourneyModel? _activeJourney;
  bool _loadingJourney = true;

  @override
  void initState() {
    super.initState();
    _initialize();
    _loadActiveJourney();
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
     _totalSteps = _stepService.totalSteps;

     _subscription = _stepService.stepStream.listen((value) {
       if (!mounted) return;
       setState(() => _steps = value);
     });

     _totalSubscription = _stepService.totalStepStream.listen((value) {
       if (!mounted) return;
       setState(() => _totalSteps = value);
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

  Future<void> _loadActiveJourney() async {
    final journey = await JourneyService.getActiveJourney();
    if (!mounted) return;
    setState(() {
      _activeJourney = (journey != null && !journey.completed) ? journey : null;
      _loadingJourney = false;
    });
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

    final journey = _activeJourney;
    final progressData = journey != null
        ? YatraProgress(journey: journey, lifetimeSteps: _totalSteps)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadActiveJourney();
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

                const SizedBox(height: 20),

                if (_loadingJourney)
                  const Center(child: CircularProgressIndicator())
                else if (journey != null && progressData != null)
                  JourneyProgressCard(
                    destination:
                        "${journey.destinationName}, ${journey.destinationLocation}",
                    walkedKm: progressData.walkedKm,
                    totalDistanceKm: progressData.totalDistanceKm,
                    backgroundImage: journey.backgroundImage,
                  )
                else
                  _NoActiveYatraCard(
                    onStart: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DestinationScreen(),
                        ),
                      );
                      _loadActiveJourney();
                    },
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

class _NoActiveYatraCard extends StatelessWidget {
  final VoidCallback onStart;
  const _NoActiveYatraCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.temple_hindu, size: 40, color: Colors.deepOrange),
            const SizedBox(height: 12),
            const Text(
              "No active Yatra yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Start a Yatra to see your journey progress here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                child: const Text("Start a Yatra"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
