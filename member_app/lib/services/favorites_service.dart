import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FavoritesService {
  static const String _prefix = "fav_";

  /// Checks if a song is marked as favorite
  static Future<bool> isFavorite(String songId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = "$_prefix${songId.trim()}";
    return prefs.getBool(key) ?? false;
  }

  /// Toggles the favorite status of a song
  /// Returns the NEW status (true = favorite, false = not favorite)
  static Future<bool> toggleFavorite(String songId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = "$_prefix${songId.trim()}";
    
    final bool currentStatus = prefs.getBool(key) ?? false;
    final bool newStatus = !currentStatus;
    
    await prefs.setBool(key, newStatus);
    debugPrint("FavoritesService: Toggled $songId to $newStatus (Key: $key)");
    
    return newStatus;
  }

  /// Returns a list of all favorite Song IDs
  static Future<List<String>> getFavoriteIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> keys = prefs.getKeys();
    final List<String> ids = [];

    for (String key in keys) {
      if (key.startsWith(_prefix)) {
        if (prefs.getBool(key) == true) {
          final String id = key.substring(_prefix.length);
          if (id.isNotEmpty) {
            ids.add(id);
          }
        }
      }
    }
    
    debugPrint("FavoritesService: Found IDs: $ids");
    return ids;
  }
}
