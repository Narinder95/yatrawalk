class UserProfile {
  final String name;
  final String baseLocation;
  final double latitude;
  final double longitude;
  final int dailyGoal;

  // Collected once at signup (profile-setup screen). Only [name] is
  // mandatory - the rest are optional wellness context.
  final int? age;
  final double? heightCm;
  final double? weightKg;

  const UserProfile({
    required this.name,
    this.baseLocation = '',
    this.latitude = 0,
    this.longitude = 0,
    this.dailyGoal = 10000,
    this.age,
    this.heightCm,
    this.weightKg,
  });

  UserProfile copyWith({
    String? name,
    String? baseLocation,
    double? latitude,
    double? longitude,
    int? dailyGoal,
    int? age,
    double? heightCm,
    double? weightKg,
  }) {
    return UserProfile(
      name: name ?? this.name,
      baseLocation: baseLocation ?? this.baseLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseLocation': baseLocation,
      'latitude': latitude,
      'longitude': longitude,
      'dailyGoal': dailyGoal,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      baseLocation: json['baseLocation'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      dailyGoal: json['dailyGoal'] ?? 10000,
      age: json['age'] as int?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
    );
  }
}