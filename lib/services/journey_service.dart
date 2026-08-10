import '../models/journey_model.dart';
import 'cloud_sync_service.dart';
import 'storage_service.dart';

class JourneyService {
  static Future<JourneyModel> createJourney(JourneyModel journey) async {
    final saved = await StorageService.saveJourney(journey);

    // Sync to cloud in background (fire-and-forget)
    if (saved.id != null) {
      CloudSyncService().syncJourney(
        journeyId: saved.id!,
        startLocation: saved.startLocation,
        destinationName: saved.destinationName,
        destinationLocation: saved.destinationLocation,
        destinationEmoji: saved.destinationEmoji,
        latitude: saved.latitude,
        longitude: saved.longitude,
        totalDistanceKm: saved.totalDistanceKm,
        completedDistanceKm: saved.completedDistanceKm,
        startDate: saved.startDate,
        startStepsSnapshot: saved.startStepsSnapshot,
        sankalp: saved.sankalp,
        completed: saved.completed,
      );
    }

    return saved;
  }

  static Future<List<JourneyModel>> loadJourneys() async {
    return StorageService.loadJourneys();
  }

  static Future<void> updateJourney(JourneyModel journey) async {
    await StorageService.updateJourney(journey);

    // Sync to cloud in background (fire-and-forget)
    if (journey.id != null) {
      CloudSyncService().syncJourney(
        journeyId: journey.id!,
        startLocation: journey.startLocation,
        destinationName: journey.destinationName,
        destinationLocation: journey.destinationLocation,
        destinationEmoji: journey.destinationEmoji,
        latitude: journey.latitude,
        longitude: journey.longitude,
        totalDistanceKm: journey.totalDistanceKm,
        completedDistanceKm: journey.completedDistanceKm,
        startDate: journey.startDate,
        startStepsSnapshot: journey.startStepsSnapshot,
        sankalp: journey.sankalp,
        completed: journey.completed,
      );
    }
  }

  static Future<JourneyModel?> getActiveJourney() async {
    return StorageService.getActiveJourney();
  }

  /// Archives [journey] (marks it completed so it stops being the active
  /// Yatra) without deleting its history. Used when the user chooses to
  /// start a brand new Yatra while one is still in progress.
  static Future<void> archiveJourney(JourneyModel journey) async {
    final archived = journey.copyWith(completed: true);
    await StorageService.updateJourney(archived);

    // Sync archived state to cloud
    if (archived.id != null) {
      CloudSyncService().syncJourney(
        journeyId: archived.id!,
        startLocation: archived.startLocation,
        destinationName: archived.destinationName,
        destinationLocation: archived.destinationLocation,
        destinationEmoji: archived.destinationEmoji,
        latitude: archived.latitude,
        longitude: archived.longitude,
        totalDistanceKm: archived.totalDistanceKm,
        completedDistanceKm: archived.completedDistanceKm,
        startDate: archived.startDate,
        startStepsSnapshot: archived.startStepsSnapshot,
        sankalp: archived.sankalp,
        completed: archived.completed,
      );
    }
  }

  static Future<void> clearJourneys() async {
    await StorageService.clearJourneys();
  }
}
