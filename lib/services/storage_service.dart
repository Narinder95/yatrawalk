import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journey_model.dart';

class StorageService {
  static const _key = 'journeys';

  /// Saves [journey], assigning it an id if it doesn't already have one,
  /// and returns the saved instance (with the id populated) so callers
  /// never lose track of it - previously this returned void and the
  /// generated id was silently discarded, which broke updateJourney
  /// matching later on.
  static Future<JourneyModel> saveJourney(JourneyModel journey) async {
    final prefs = await SharedPreferences.getInstance();
    final journeys = await loadJourneys();
    final safeJourney = journey.copyWith(
      id: journey.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );

    journeys.add(safeJourney);
    final encoded = journeys.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(_key, encoded);

    return safeJourney;
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

  /// Updates a journey already in storage (matched by [JourneyModel.id]).
  /// If no journey with that id exists yet, it's appended instead.
  static Future<void> updateJourney(JourneyModel journey) async {
    final prefs = await SharedPreferences.getInstance();
    final journeys = await loadJourneys();

    final index = journeys.indexWhere((j) => j.id == journey.id);

    if (index == -1) {
      journeys.add(journey);
    } else {
      journeys[index] = journey;
    }

    final encoded = journeys.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  /// Returns the most recent journey that hasn't been marked completed yet,
  /// or the most recent journey overall if all are completed.
  /// Returns null if the user has never started a Yatra.
  static Future<JourneyModel?> getActiveJourney() async {
    final journeys = await loadJourneys();
    if (journeys.isEmpty) return null;

    for (final journey in journeys.reversed) {
      if (!journey.completed) {
        return journey;
      }
    }

    return journeys.last;
  }

  static Future<bool> hasActiveJourney() async {
    final journey = await getActiveJourney();
    return journey != null && !journey.completed;
  }

  static Future<void> clearJourneys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
