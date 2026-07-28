import 'package:shared_preferences/shared_preferences.dart';

class UserService {

  static const String journeyKey = "hasJourney";

  static Future<bool> hasJourney() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(journeyKey) ?? false;
  }


  static Future<void> createJourney() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(journeyKey, true);
  }


  static Future<void> resetJourney() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(journeyKey, false);
  }
}