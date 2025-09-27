import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/topic.dart';
import 'api_service.dart';

class ApiIntegratedFavoritesService {
  static const String _favoritesKey = 'favorite_lessons';
  static ApiIntegratedFavoritesService? _instance;

  ApiIntegratedFavoritesService._internal();

  static ApiIntegratedFavoritesService get instance {
    _instance ??= ApiIntegratedFavoritesService._internal();
    return _instance!;
  }

  final ApiService _apiService = ApiService();

  // Get all favorite lessons
  Future<List<Lesson>> getFavorites() async {
    try {
      // Try to get from API first if user is logged in
      if (await _apiService.isLoggedIn()) {
        return await _apiService.getFavorites();
      }

      // Fallback to local storage for offline mode
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.map((jsonString) {
        final json = jsonDecode(jsonString);
        return Lesson.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.map((jsonString) {
        final json = jsonDecode(jsonString);
        return Lesson.fromJson(json);
      }).toList();
    }
  }

  // Add lesson to favorites
  Future<bool> addToFavorites(Lesson lesson) async {
    try {
      // Try API first if user is logged in
      if (await _apiService.isLoggedIn()) {
        final success = await _apiService.addToFavorites(int.parse(lesson.id));
        if (success) {
          // Also update local cache
          await _addToLocalFavorites(lesson);
          return true;
        }
        return false;
      }

      // Fallback to local storage
      return await _addToLocalFavorites(lesson);
    } catch (e) {
      print('Error adding to favorites: $e');
      // Fallback to local storage
      return await _addToLocalFavorites(lesson);
    }
  }

  // Remove lesson from favorites
  Future<bool> removeFromFavorites(String lessonId) async {
    try {
      // Try API first if user is logged in
      if (await _apiService.isLoggedIn()) {
        final success =
            await _apiService.removeFromFavorites(int.parse(lessonId));
        if (success) {
          // Also update local cache
          await _removeFromLocalFavorites(lessonId);
          return true;
        }
        return false;
      }

      // Fallback to local storage
      return await _removeFromLocalFavorites(lessonId);
    } catch (e) {
      print('Error removing from favorites: $e');
      // Fallback to local storage
      return await _removeFromLocalFavorites(lessonId);
    }
  }

  // Check if lesson is in favorites
  Future<bool> isFavorite(String lessonId) async {
    try {
      // Try API first if user is logged in
      if (await _apiService.isLoggedIn()) {
        return await _apiService.isFavorite(int.parse(lessonId));
      }

      // Fallback to local storage
      final favorites = await _getLocalFavorites();
      return favorites.any((lesson) => lesson.id == lessonId);
    } catch (e) {
      print('Error checking favorite status: $e');
      // Fallback to local storage
      final favorites = await _getLocalFavorites();
      return favorites.any((lesson) => lesson.id == lessonId);
    }
  }

  // Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      // Try API first if user is logged in
      if (await _apiService.isLoggedIn()) {
        final success = await _apiService.clearFavorites();
        if (success) {
          // Also clear local cache
          await _clearLocalFavorites();
          return true;
        }
        return false;
      }

      // Fallback to local storage
      return await _clearLocalFavorites();
    } catch (e) {
      print('Error clearing favorites: $e');
      // Fallback to local storage
      return await _clearLocalFavorites();
    }
  }

  // Sync local favorites with API when user logs in
  Future<void> syncFavoritesWithApi() async {
    try {
      if (!await _apiService.isLoggedIn()) return;

      final localFavorites = await _getLocalFavorites();
      final apiFavoriteIds = await _apiService.getFavoriteIds();

      // Add local favorites to API that don't exist there
      for (final lesson in localFavorites) {
        final lessonIdInt = int.tryParse(lesson.id);
        if (lessonIdInt != null && !apiFavoriteIds.contains(lessonIdInt)) {
          await _apiService.addToFavorites(lessonIdInt);
        }
      }

      // Update local cache with API favorites
      final apiFavorites = await _apiService.getFavorites();
      await _storeLocalFavorites(apiFavorites);
    } catch (e) {
      print('Error syncing favorites: $e');
    }
  }

  // Local storage helper methods
  Future<List<Lesson>> _getLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.map((jsonString) {
        final json = jsonDecode(jsonString);
        return Lesson.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading local favorites: $e');
      return [];
    }
  }

  Future<bool> _addToLocalFavorites(Lesson lesson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await _getLocalFavorites();

      // Check if lesson is already in favorites
      if (favorites.any((fav) => fav.id == lesson.id)) {
        return false; // Already in favorites
      }

      favorites.add(lesson);
      final favoritesJson =
          favorites.map((lesson) => jsonEncode(lesson.toJson())).toList();

      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error adding to local favorites: $e');
      return false;
    }
  }

  Future<bool> _removeFromLocalFavorites(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await _getLocalFavorites();

      final initialLength = favorites.length;
      favorites.removeWhere((lesson) => lesson.id == lessonId);

      if (favorites.length == initialLength) {
        return false; // Lesson was not in favorites
      }

      final favoritesJson =
          favorites.map((lesson) => jsonEncode(lesson.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error removing from local favorites: $e');
      return false;
    }
  }

  Future<bool> _clearLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing local favorites: $e');
      return false;
    }
  }

  Future<void> _storeLocalFavorites(List<Lesson> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          favorites.map((lesson) => jsonEncode(lesson.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error storing local favorites: $e');
    }
  }
}
