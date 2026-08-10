import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mantra_model.dart';
import 'cloud_sync_service.dart';

class MantraService {
  MantraService._internal();
  static final MantraService _instance = MantraService._internal();
  factory MantraService() => _instance;

  static const _recitationsKey = 'mantra_recitations';

  // Default mantras and poojas for daily engagement
  // Add your own audio URLs from free resources like:
  // - YouTube Music (extract direct links)
  // - Freesound.org (free sound effects & music)
  // - Pixabay Music (free audio library)
  // - Pexels Videos (free video/audio)
  // - SoundCloud (public tracks)
  static final List<Mantra> _defaultMantras = [
    Mantra(
      id: 'om-namah-shivaya',
      title: 'Om Namah Shivaya',
      category: 'Mantra',
      text: 'ॐ नमः शिवाय',
      meaning: 'I bow to Shiva, the supreme consciousness. This mantra represents purification and inner transformation.',
      audioUrl: null, // Add your audio URL here
      order: 1,
    ),
    Mantra(
      id: 'gayatri-mantra',
      title: 'Gayatri Mantra',
      category: 'Mantra',
      text: 'ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्',
      meaning: 'The Gayatri Mantra is one of the oldest and most powerful mantras, dedicated to the sun god Surya. It is believed to illuminate the mind and grant wisdom.',
      audioUrl: null, // Add your audio URL here
      order: 2,
    ),
    Mantra(
      id: 'maha-mrityunjaya',
      title: 'Maha Mrityunjaya Mantra',
      category: 'Mantra',
      text: 'ॐ त्र्यम्बकं यजामहे\nसुगन्धिं पुष्टिवर्धनम्\nउर्वारुकमिव बन्धनान्\nमृत्योर्मुक्षीय मामृतात्',
      meaning: 'The Maha Mrityunjaya Mantra is a powerful healing mantra dedicated to Lord Shiva. It promotes health, vitality, and spiritual growth.',
      audioUrl: null, // Add your audio URL here
      order: 3,
    ),
    Mantra(
      id: 'morning-prayer',
      title: 'Morning Prayer',
      category: 'Pooja',
      text: 'उदयते सविता एषः\nद्यौः सूर्येण प्रकाशिता\nहे भास्कर नमस्तुभ्यं\nदेव प्रकाशमे कुरु',
      meaning: 'A traditional morning prayer to welcome the rising sun and begin the day with positive energy.',
      audioUrl: null, // Add your audio URL here
      order: 4,
    ),
    Mantra(
      id: 'evening-prayer',
      title: 'Evening Prayer',
      category: 'Pooja',
      text: 'दिवसांतम् गतं सूर्य:\nनमामि तव चरणे\nनिशां कृष्णमहं तेषां\nभज आध्यात्मिक शक्तिम्',
      meaning: 'An evening prayer to thank the sun for the day and prepare the mind for rest and reflection.',
      audioUrl: null, // Add your audio URL here
      order: 5,
    ),
  ];

  Future<List<Mantra>> getMantras() async {
    return _defaultMantras;
  }

  Future<bool> hasRecitedToday(String mantraId) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    final recitations = await _getRecitations();
    return recitations.any(
      (r) => r.mantraId == mantraId &&
            r.date.toString().startsWith(todayStr),
    );
  }

  Future<void> markAsRecited(String mantraId) async {
    final recitations = await _getRecitations();
    final now = DateTime.now();

    // Avoid duplicate entries for the same day
    final alreadyRecited = recitations.any(
      (r) => r.mantraId == mantraId &&
            r.date.year == now.year &&
            r.date.month == now.month &&
            r.date.day == now.day,
    );

    if (!alreadyRecited) {
      recitations.add(MantraRecitation(mantraId: mantraId, date: now));
      await _saveRecitations(recitations);

      // Sync to cloud in background (fire-and-forget)
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      CloudSyncService().syncMantraRecitation(
        mantraId: mantraId,
        date: dateStr,
      );
    }
  }

  Future<int> getTodayRecitationCount() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    final recitations = await _getRecitations();
    return recitations
        .where((r) => r.date.toString().startsWith(todayStr))
        .length;
  }

  Future<List<MantraRecitation>> _getRecitations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recitationsKey);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => MantraRecitation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRecitations(List<MantraRecitation> recitations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recitationsKey,
      jsonEncode(recitations.map((r) => r.toJson()).toList()),
    );
  }
}
