class JourneyModel {
  final String? id;

  final String startLocation;

  final String destinationName;
  final String destinationLocation;
  final String destinationEmoji;
  final String backgroundImage;

  final double latitude;
  final double longitude;

  // Total pilgrimage distance
  final double totalDistanceKm;

  // Completed distance based on steps
  final double completedDistanceKm;

  final DateTime startDate;

  // Lifetime step count at the moment this Yatra was created. Used to work
  // out how many steps have been taken *for this Yatra specifically*
  // (StepService.totalSteps - startStepsSnapshot), so switching or
  // restarting a Yatra doesn't inherit progress from a previous one.
  final int startStepsSnapshot;

  // User pledge
  final String sankalp;

  final bool completed;

  JourneyModel({
    this.id,
    required this.startLocation,
    required this.destinationName,
    required this.destinationLocation,
    this.destinationEmoji = "🛕",
    this.backgroundImage = 'assets/images/hero-backgrounds/background_1.png',
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.totalDistanceKm,
    this.completedDistanceKm = 0,
    required this.startDate,
    this.startStepsSnapshot = 0,
    required this.sankalp,
    this.completed = false,
  });

  JourneyModel copyWith({
    String? id,
    String? startLocation,
    String? destinationName,
    String? destinationLocation,
    String? destinationEmoji,
    String? backgroundImage,
    double? latitude,
    double? longitude,
    double? totalDistanceKm,
    double? completedDistanceKm,
    DateTime? startDate,
    int? startStepsSnapshot,
    String? sankalp,
    bool? completed,
  }) {
    return JourneyModel(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      destinationName: destinationName ?? this.destinationName,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      destinationEmoji: destinationEmoji ?? this.destinationEmoji,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      completedDistanceKm: completedDistanceKm ?? this.completedDistanceKm,
      startDate: startDate ?? this.startDate,
      startStepsSnapshot: startStepsSnapshot ?? this.startStepsSnapshot,
      sankalp: sankalp ?? this.sankalp,
      completed: completed ?? this.completed,
    );
  }

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id']?.toString(),
      startLocation: json['startLocation']?.toString() ?? "",
      destinationName: json['destinationName']?.toString() ?? "",
      destinationLocation: json['destinationLocation']?.toString() ?? "",
      destinationEmoji: json['destinationEmoji']?.toString() ?? "🛕",
      backgroundImage: json['backgroundImage']?.toString() ?? 'assets/images/hero-backgrounds/background_1.png',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      completedDistanceKm:
          (json['completedDistanceKm'] as num?)?.toDouble() ?? 0,
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? "") ??
          DateTime.now(),
      startStepsSnapshot: (json['startStepsSnapshot'] as num?)?.toInt() ?? 0,
      sankalp: json['sankalp']?.toString() ?? "",
      completed: json['completed'] == true || json['completed'] == "true",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "startLocation": startLocation,
      "destinationName": destinationName,
      "destinationLocation": destinationLocation,
      "destinationEmoji": destinationEmoji,
      "backgroundImage": backgroundImage,
      "latitude": latitude,
      "longitude": longitude,
      "totalDistanceKm": totalDistanceKm,
      "completedDistanceKm": completedDistanceKm,
      "startDate": startDate.toIso8601String(),
      "startStepsSnapshot": startStepsSnapshot,
      "sankalp": sankalp,
      "completed": completed,
    };
  }

  double get progressPercentage {
    if (totalDistanceKm == 0) {
      return 0;
    }
    return (completedDistanceKm / totalDistanceKm).clamp(0, 1);
  }

  @override
  String toString() {
    return """
Journey:
From: $startLocation
To: $destinationName
Distance: $completedDistanceKm / $totalDistanceKm km
Sankalp: $sankalp
Completed: $completed
""";
  }
}
