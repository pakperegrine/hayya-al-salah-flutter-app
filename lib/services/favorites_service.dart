import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/topic.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_lessons';
  static FavoritesService? _instance;

  FavoritesService._internal();

  static FavoritesService get instance {
    _instance ??= FavoritesService._internal();
    return _instance!;
  }

  // Get all favorite lessons
  Future<List<Lesson>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.map((jsonString) {
        final json = jsonDecode(jsonString);
        return Lesson.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  // Add lesson to favorites
  Future<bool> addToFavorites(Lesson lesson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

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
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove lesson from favorites
  Future<bool> removeFromFavorites(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

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
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Check if lesson is in favorites
  Future<bool> isFavorite(String lessonId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((lesson) => lesson.id == lessonId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }
}
