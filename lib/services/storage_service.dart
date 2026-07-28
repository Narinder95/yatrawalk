import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journey.dart';

class StorageService {
  static const _key = 'journeys';

  static Future<void> saveJourney(JourneyModel journey) async {
    final prefs = await SharedPreferences.getInstance();
    final journeys = await loadJourneys();
    final safeJourney = journey.copyWith(
      id: journey.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );

    journeys.add(safeJourney);
    final encoded = journeys.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  static Future<List<JourneyModel>> loadJourneys() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? <String>[];

    return data.map((entry) {
      final decoded = jsonDecode(entry);
      if (decoded is Map) {
        return JourneyModel.fromJson(Map<String, dynamic>.from(decoded));
      }
      return JourneyModel(
        startLocation: '',
        destinationName: '',
        destinationLocation: '',
        totalDistanceKm: 0.0,
        startDate: DateTime.now(),
        sankalp: '',
      );
    }).toList();
  }

  static Future<void> clearJourneys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}