class Sankalp {
  final String id;
  final String title;
  final String description;
  final bool isComplete;
  final DateTime createdDate;
  final DateTime? completedDate;
  final bool isActive;
  final String? emoji;

  const Sankalp({
    required this.id,
    required this.title,
    required this.description,
    required this.isComplete,
    required this.createdDate,
    this.completedDate,
    required this.isActive,
    this.emoji,
  });

  Sankalp copyWith({
    String? id,
    String? title,
    String? description,
    bool? isComplete,
    DateTime? createdDate,
    DateTime? completedDate,
    bool? isActive,
    String? emoji,
  }) =>
      Sankalp(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isComplete: isComplete ?? this.isComplete,
        createdDate: createdDate ?? this.createdDate,
        completedDate: completedDate ?? this.completedDate,
        isActive: isActive ?? this.isActive,
        emoji: emoji ?? this.emoji,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isComplete': isComplete,
    'createdDate': createdDate.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'isActive': isActive,
    'emoji': emoji,
  };

  factory Sankalp.fromJson(Map<String, dynamic> json) {
    try {
      return Sankalp(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        isComplete: _parseBool(json['isComplete']),
        createdDate: DateTime.parse(json['createdDate']?.toString() ?? DateTime.now().toIso8601String()),
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'].toString())
            : null,
        isActive: _parseBool(json['isActive']),
        emoji: json['emoji']?.toString(),
      );
    } catch (e) {
      print('Error parsing sankalp JSON: $e, data: $json');
      rethrow;
    }
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }
}
