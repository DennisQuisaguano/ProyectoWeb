import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _savedCampusKey = 'saved_campus_id';
  static const String _favoritesKey = 'saved_favorite_locales';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    await init();
    return _prefs!.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    await init();
    await _prefs!.remove(_tokenKey);
  }

  // User
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await init();
    await _prefs!.setString(_userKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    await init();
    final data = _prefs!.getString(_userKey);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeUser() async {
    await init();
    await _prefs!.remove(_userKey);
  }

  // Campus preferido
  static Future<void> saveSelectedCampus(int campusId) async {
    await init();
    await _prefs!.setInt(_savedCampusKey, campusId);
  }

  static Future<int> getSelectedCampus() async {
    await init();
    return _prefs!.getInt(_savedCampusKey) ?? 1; // Default Campus Huachi
  }

  // Locales Favoritos / Guardados
  static Future<List<String>> getFavoriteLocalIds() async {
    await init();
    return _prefs!.getStringList(_favoritesKey) ?? [];
  }

  static Future<bool> toggleFavoriteLocal(String localId) async {
    await init();
    final list = _prefs!.getStringList(_favoritesKey) ?? [];
    bool isFav;
    if (list.contains(localId)) {
      list.remove(localId);
      isFav = false;
    } else {
      list.add(localId);
      isFav = true;
    }
    await _prefs!.setStringList(_favoritesKey, list);
    return isFav;
  }

  static Future<bool> isFavorite(String localId) async {
    await init();
    final list = _prefs!.getStringList(_favoritesKey) ?? [];
    return list.contains(localId);
  }

  static const String _onboardingSeenKey = 'has_seen_onboarding_v1';

  static Future<bool> hasSeenOnboarding() async {
    await init();
    return _prefs!.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    await init();
    await _prefs!.setBool(_onboardingSeenKey, true);
  }

  static Future<void> clearSession() async {
    await removeToken();
    await removeUser();
  }
}
