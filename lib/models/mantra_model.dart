class Mantra {
  final String id;
  final String title;
  final String category; // "Mantra", "Pooja", "Affirmation"
  final String text;
  final String? meaning;
  final String? audioUrl;
  final int order;

  const Mantra({
    required this.id,
    required this.title,
    required this.category,
    required this.text,
    this.meaning,
    this.audioUrl,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'text': text,
    'meaning': meaning,
    'audioUrl': audioUrl,
    'order': order,
  };

  factory Mantra.fromJson(Map<String, dynamic> json) => Mantra(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    text: json['text'] as String,
    meaning: json['meaning'] as String?,
    audioUrl: json['audioUrl'] as String?,
    order: json['order'] as int? ?? 0,
  );
}

class MantraRecitation {
  final String mantraId;
  final DateTime date;

  const MantraRecitation({
    required this.mantraId,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'mantraId': mantraId,
    'date': date.toIso8601String(),
  };

  factory MantraRecitation.fromJson(Map<String, dynamic> json) => MantraRecitation(
    mantraId: json['mantraId'] as String,
    date: DateTime.parse(json['date'] as String),
  );
}
