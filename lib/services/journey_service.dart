import '../models/journey.dart';
import 'storage_service.dart';

class JourneyService {
  static Future<JourneyModel?> createJourney(JourneyModel journey) async {
    await StorageService.saveJourney(journey);
    return journey;
  }

  static Future<List<JourneyModel>> loadJourneys() async {
    return StorageService.loadJourneys();
  }

  static Future<void> clearJourneys() async {
    await StorageService.clearJourneys();
  }
}