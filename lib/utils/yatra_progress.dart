import '../models/journey_model.dart';

/// Single source of truth for all Yatra progress math.
///
/// Every screen that shows Yatra progress (Home dashboard, Steps tab,
/// Journey details) must build its numbers from this class instead of
/// recomputing them locally - that's what caused Home and Steps to show
/// different, inconsistent numbers before.
class YatraProgress {
  // Rough conversion used across the app: 1 step ≈ 0.8 metres.
  static const double kKmPerStep = 0.0008;

  final JourneyModel journey;
  final int lifetimeSteps;

  YatraProgress({required this.journey, required this.lifetimeSteps});

  /// Steps taken specifically towards *this* Yatra (lifetime steps minus
  /// whatever the counter already read when the Yatra was created), so a
  /// new/restarted Yatra always starts at 0%.
  int get yatraSteps =>
      (lifetimeSteps - journey.startStepsSnapshot).clamp(0, 1 << 62);

  double get walkedKm => yatraSteps * kKmPerStep;

  double get totalDistanceKm => journey.totalDistanceKm;

  double get remainingKm =>
      (totalDistanceKm - walkedKm).clamp(0, totalDistanceKm);

  /// 0.0 - 1.0
  double get progress =>
      totalDistanceKm > 0 ? (walkedKm / totalDistanceKm).clamp(0.0, 1.0) : 0.0;

  double get progressPercent => progress * 100;

  int get daysOnYatra =>
      DateTime.now().difference(journey.startDate).inDays + 1;

  bool get isComplete => progress >= 1.0;
}
