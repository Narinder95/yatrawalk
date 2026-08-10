/// A single member of a Yatra Family group.
///
/// This is intentionally backend-agnostic: whether the data comes from
/// SharedPreferences (local, single-device demo) or a cloud database
/// (once real multi-device sync is added), it gets mapped into this same
/// shape for the UI to render.
class FamilyMember {
  final String id;
  final String name;
  final String avatarEmoji;
  final int totalSteps;
  final int todaySteps;
  final bool isCurrentUser;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.totalSteps,
    required this.todaySteps,
    this.isCurrentUser = false,
  });

  double get distanceKm => totalSteps * 0.0008;
}
