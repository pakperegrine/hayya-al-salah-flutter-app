import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _autoPlayKey = 'auto_play_enabled';
  static const String _languageKey = 'selected_language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _wifiOnlyKey = 'wifi_only_downloads';
  static const String _offlineVideosKey = 'offline_videos_enabled';

  // Default values
  bool _autoPlayEnabled = false;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _wifiOnlyDownloads = true;
  bool _offlineVideosEnabled = false;

  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Getters
  bool get autoPlayEnabled => _autoPlayEnabled;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get wifiOnlyDownloads => _wifiOnlyDownloads;
  bool get offlineVideosEnabled => _offlineVideosEnabled;

  // Available options
  List<String> get availableLanguages => [
        'English',
        'Arabic',
        'Urdu'
      ]; // Initialize settings from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _autoPlayEnabled = prefs.getBool(_autoPlayKey) ?? false;
    _selectedLanguage = prefs.getString(_languageKey) ?? 'English';
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _wifiOnlyDownloads = prefs.getBool(_wifiOnlyKey) ?? true;
    _offlineVideosEnabled = prefs.getBool(_offlineVideosKey) ?? false;

    notifyListeners();
  }

  // Auto Play Settings
  Future<void> setAutoPlay(bool enabled) async {
    if (_autoPlayEnabled == enabled) return;

    _autoPlayEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, enabled);
    notifyListeners();
  }

  Future<void> toggleAutoPlay() async {
    await setAutoPlay(!_autoPlayEnabled);
  }

  // Language Settings
  Future<void> setLanguage(String language) async {
    if (_selectedLanguage == language) return;

    if (!availableLanguages.contains(language)) {
      throw ArgumentError('Unsupported language: $language');
    }

    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }

  // Notifications Settings
  Future<void> setNotifications(bool enabled) async {
    if (_notificationsEnabled == enabled) return;

    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    await setNotifications(!_notificationsEnabled);
  } // WiFi Only Downloads Settings

  Future<void> setWifiOnlyDownloads(bool enabled) async {
    if (_wifiOnlyDownloads == enabled) return;

    _wifiOnlyDownloads = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wifiOnlyKey, enabled);
    notifyListeners();
  }

  Future<void> toggleWifiOnlyDownloads() async {
    await setWifiOnlyDownloads(!_wifiOnlyDownloads);
  }

  // Offline Videos Settings
  Future<void> setOfflineVideos(bool enabled) async {
    if (_offlineVideosEnabled == enabled) return;

    _offlineVideosEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineVideosKey, enabled);
    notifyListeners();
  }

  Future<void> toggleOfflineVideos() async {
    await setOfflineVideos(!_offlineVideosEnabled);
  }

  // Get locale based on selected language
  Locale get currentLocale {
    switch (_selectedLanguage) {
      case 'Arabic':
        return const Locale('ar', 'SA');
      case 'Urdu':
        return const Locale('ur', 'PK');
      default:
        return const Locale('en', 'US');
    }
  }

  // Check if current language is RTL
  bool get isRTL {
    return _selectedLanguage == 'Arabic' || _selectedLanguage == 'Urdu';
  } // Reset all settings to default

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_autoPlayKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove(_wifiOnlyKey);
    await prefs.remove(_offlineVideosKey);

    _autoPlayEnabled = false;
    _selectedLanguage = 'English';
    _notificationsEnabled = true;
    _wifiOnlyDownloads = true;
    _offlineVideosEnabled = true;

    notifyListeners();
  }

  // Get settings summary for debugging
  Map<String, dynamic> getSettingsSummary() {
    return {
      'autoPlay': _autoPlayEnabled,
      'language': _selectedLanguage,
      'notifications': _notificationsEnabled,
      'wifiOnly': _wifiOnlyDownloads,
      'offlineVideos': _offlineVideosEnabled,
      'locale': currentLocale.toString(),
      'isRTL': isRTL,
    };
  }
}
