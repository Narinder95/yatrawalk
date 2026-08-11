import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart' show routeObserver;
import '../models/journey_model.dart';
import '../services/journey_service.dart';
import '../services/sankalp_service.dart';
import '../services/step_service.dart';
import '../services/user_profile_service.dart';
import '../utils/yatra_progress.dart';
import '../widgets/sankalp_card.dart';
import '../widgets/yatra_hero_animation.dart';
import '../widgets/yatra_stat_tile.dart';
import 'destination_screen.dart';
import 'family/family_screen.dart';
import 'mantras/mantras_screen.dart';
import 'profile/profile_screen.dart';
import 'steps/steps_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onViewSteps: () => _goToTab(1)),
      const StepsScreen(),
      const MantrasScreen(),
      const FamilyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F2),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: "Steps",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: "Mantras",
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.family_restroom),
            label: "Family",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  /// Switches Home's bottom nav to the Steps tab, which shows the full,
  /// authoritative progress view for the active Yatra.
  final VoidCallback onViewSteps;

  const DashboardScreen({super.key, required this.onViewSteps});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  final StepService _stepService = StepService();
  final UserProfileService _profileService = UserProfileService();

  StreamSubscription<int>? _todayStepsSub;
  StreamSubscription<int>? _totalStepsSub;
  StreamSubscription<int>? _dailyGoalSub;

  int _todaySteps = 0;
  int _totalSteps = 0;
  int _dailyGoal = 10000;
  int _streakDays = 0;
  bool _sankalpCheckedIn = false;
  String _userName = '';

  JourneyModel? _activeJourney;
  bool _loadingJourney = true;

  @override
  void initState() {
    super.initState();

    _todaySteps = _stepService.todaySteps;
    _totalSteps = _stepService.totalSteps;

    // Make sure the step service is running so numbers update live even if
    // the Steps tab hasn't been opened yet.
    _stepService.start();

    _todayStepsSub = _stepService.stepStream.listen((steps) {
      if (!mounted) return;
      setState(() => _todaySteps = steps);
    });

    _totalStepsSub = _stepService.totalStepStream.listen((total) {
      if (!mounted) return;
      setState(() => _totalSteps = total);
    });

    _loadActiveJourney();
    _loadProfile();
    _loadStreak();

    _dailyGoalSub = _profileService.dailyGoalStream.listen((goal) {
      if (!mounted) return;
      setState(() => _dailyGoal = goal);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _todayStepsSub?.cancel();
    _totalStepsSub?.cancel();
    _dailyGoalSub?.cancel();
    super.dispose();
  }

  // Called by RouteObserver whenever a screen pushed on top of Home (e.g.
  // the Destination picker) is popped and this screen becomes visible
  // again. This is what keeps the dashboard in sync after starting or
  // updating a Yatra elsewhere in the app.
  @override
  void didPopNext() {
    _loadActiveJourney();
    _loadProfile();
    _loadStreak();
  }

  Future<void> _loadActiveJourney() async {
    final journey = await JourneyService.getActiveJourney();
    final activeJourney =
        (journey != null && !journey.completed) ? journey : null;

    if (!mounted) return;

    bool checkedIn = false;
    if (activeJourney?.id != null) {
      checkedIn = await SankalpService.isCheckedInToday(activeJourney!.id!);
    }

    if (!mounted) return;
    setState(() {
      _activeJourney = activeJourney;
      _loadingJourney = false;
      _sankalpCheckedIn = checkedIn;
    });
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.loadProfile();
    if (!mounted) return;
    setState(() {
      _userName = profile.name.isNotEmpty ? profile.name : 'Guest';
      _dailyGoal = profile.dailyGoal;
    });
  }

  Future<void> _loadStreak() async {
    final streak = await _stepService.getStreakDays();
    if (!mounted) return;
    setState(() => _streakDays = streak);
  }

  /// Starting a new Yatra (or replacing an active, incomplete one) is
  /// always handled by DestinationScreen, which warns the user and
  /// archives the old Yatra if needed - this is the single source of
  /// truth for that flow so Home and Steps never disagree about which
  /// Yatra is "active".
  Future<void> _onStartOrPickDestination() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DestinationScreen()),
    );
    _loadActiveJourney();
  }

  Future<void> _onSankalpCheckIn() async {
    final journey = _activeJourney;
    if (journey?.id == null) return;
    await SankalpService.checkInToday(journey!.id!);
    if (!mounted) return;
    setState(() => _sankalpCheckedIn = true);
  }

  Future<void> _onEditSankalp() async {
    final journey = _activeJourney;
    if (journey == null) return;

    final controller = TextEditingController(text: journey.sankalp);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Renew your Sankalp"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "e.g. I will walk with faith and discipline.",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    final updated = journey.copyWith(sankalp: result.trim());
    await JourneyService.updateJourney(updated);
    if (!mounted) return;
    setState(() => _activeJourney = updated);
  }

  @override
  Widget build(BuildContext context) {
    final journey = _activeJourney;

    final progressData = journey != null
        ? YatraProgress(journey: journey, lifetimeSteps: _totalSteps)
        : null;

    final walkedKm = progressData?.walkedKm ?? 0;
    final totalDistanceKm = progressData?.totalDistanceKm ?? 0;
    final progress = progressData?.progress ?? 0.0;
    final remainingKm = progressData?.remainingKm ?? 0;
    final daysOnYatra = progressData?.daysOnYatra ?? 0;
    final yatraSteps = progressData?.yatraSteps ?? 0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadActiveJourney();
          await _loadProfile();
          await _loadStreak();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "🙏 DigiTeerth",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Welcome back, $_userName!",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 20),

            // --- Animated current-Yatra hero card ---
            if (!_loadingJourney)
              YatraHeroAnimation(
                key: ValueKey(journey?.id),
                hasJourney: journey != null,
                progress: progress,
                destinationEmoji: journey?.destinationEmoji ?? "🛕",
                destinationName: journey != null
                    ? "${journey.destinationName}, ${journey.destinationLocation}"
                    : "",
                walkedKm: walkedKm,
                totalDistanceKm: totalDistanceKm,
                streakDays: _streakDays,
              )
            else
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),

            // --- Daily Sankalp ritual ---
            if (!_loadingJourney && journey != null) ...[
              const SizedBox(height: 16),
              SankalpCard(
                sankalp: journey.sankalp,
                checkedInToday: _sankalpCheckedIn,
                onCheckIn: _onSankalpCheckIn,
                onEdit: _onEditSankalp,
              ),
            ],

            const SizedBox(height: 24),

            // --- Metrics grid ---
            Text(
              "Your Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),

            _StatsGrid(
              tiles: [
                YatraStatTile(
                  icon: Icons.directions_walk,
                  color: Colors.deepOrange,
                  value: journey != null ? "$yatraSteps" : "--",
                  label: "Yatra Steps",
                ),
                YatraStatTile(
                  icon: Icons.today,
                  color: Colors.blue,
                  value: "$_todaySteps / $_dailyGoal",
                  label: "Today's Steps",
                ),
                YatraStatTile(
                  icon: Icons.percent,
                  color: Colors.green,
                  value: journey != null
                      ? "${(progress * 100).toStringAsFixed(1)}%"
                      : "0%",
                  label: "Yatra Completed",
                ),
                YatraStatTile(
                  icon: Icons.route,
                  color: Colors.purple,
                  value: journey != null
                      ? "${remainingKm.toStringAsFixed(0)} km"
                      : "--",
                  label: "Distance Remaining",
                ),
                YatraStatTile(
                  icon: Icons.local_fire_department,
                  color: Colors.red,
                  value: "$_streakDays",
                  label: "Day Streak",
                ),
                YatraStatTile(
                  icon: Icons.flag,
                  color: Colors.teal,
                  value: journey != null
                      ? "${totalDistanceKm.toStringAsFixed(0)} km"
                      : "--",
                  label: "Total Distance",
                ),
              ],
            ),

            const SizedBox(height: 28),

            // --- Primary action button ---
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _loadingJourney
                    ? null
                    : (journey == null
                        ? _onStartOrPickDestination
                        : widget.onViewSteps),
                icon: Icon(
                  journey == null ? Icons.add_location_alt : Icons.insights,
                ),
                label: Text(
                  journey == null ? "Start New Yatra" : "View Journey Progress",
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),

            // --- Secondary action: start a fresh Yatra over an active one.
            // DestinationScreen itself warns before archiving the current
            // Yatra, so this is the one and only place that flow lives. ---
            if (!_loadingJourney && journey != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    side: const BorderSide(color: Colors.deepOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _onStartOrPickDestination,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text(
                    "Start New Yatra",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Lays out stat tiles two-per-row using rows sized by their own content
/// (via IntrinsicHeight) instead of GridView's fixed aspect ratio, which
/// was clipping/overflowing on smaller screens or longer text.
class _StatsGrid extends StatelessWidget {
  final List<Widget> tiles;

  const _StatsGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < tiles.length; i += 2) {
      final hasSecond = i + 1 < tiles.length;

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[i]),
              const SizedBox(width: 14),
              Expanded(child: hasSecond ? tiles[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );

      if (i + 2 < tiles.length) {
        rows.add(const SizedBox(height: 14));
      }
    }

    return Column(children: rows);
  }
}
