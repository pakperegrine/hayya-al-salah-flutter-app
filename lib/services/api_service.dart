import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification.dart';
import '../models/topic.dart';

class ApiService {
  static const String baseUrl = 'https://salah.imtiazkausar.org.pk/api';
  static const String tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // Initialize with stored token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(tokenKey);
  }

  // Get headers with authentication if available
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Store auth token
  Future<void> _storeToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Clear auth token
  Future<void> _clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Authentication Methods
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['token'] != null) {
        await _storeToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        await _storeToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  Future<bool> isLoggedIn() async {
    await initialize();
    return _authToken != null;
  }

  // Topics Methods
  Future<List<Topic>> getTopics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/topics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((topicJson) => Topic.fromApiJson(topicJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching topics: $e');
      return [];
    }
  }

  Future<Topic?> getTopic(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/topics/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Topic.fromApiJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching topic: $e');
      return null;
    }
  }

  // Lectures Methods
  Future<List<Lesson>> getLectures({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri =
          Uri.parse('$baseUrl/lectures').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((lectureJson) => Lesson.fromApiJson(lectureJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching lectures: $e');
      return [];
    }
  }

  Future<Lesson?> getLecture(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lectures/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Lesson.fromApiJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching lecture: $e');
      return null;
    }
  }

  Future<List<Lesson>> getLecturesByTopic(int topicId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/topics/$topicId/lectures'),
        headers: {..._headers, 'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        // Ensure proper UTF-8 decoding
        final bodyBytes = response.bodyBytes;
        final bodyString = utf8.decode(bodyBytes);
        final data = jsonDecode(bodyString);

        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((lectureJson) => Lesson.fromApiJson(lectureJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching lectures by topic: $e');
      return [];
    }
  }

  Future<List<Lesson>> getPopularLectures({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lectures/popular?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((lectureJson) => Lesson.fromApiJson(lectureJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching popular lectures: $e');
      return [];
    }
  }

  Future<List<Lesson>> getRecentLectures({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lectures/recent?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((lectureJson) => Lesson.fromApiJson(lectureJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching recent lectures: $e');
      return [];
    }
  }

  // Favorites Methods (requires authentication)
  Future<List<Lesson>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/favorites'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((lectureJson) => Lesson.fromApiJson(lectureJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<List<int>> getFavoriteIds() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/favorites/ids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<int>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching favorite IDs: $e');
      return [];
    }
  }

  Future<bool> isFavorite(int lectureId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/favorites/check/$lectureId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<bool> addToFavorites(int lectureId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/favorites/$lectureId'),
        headers: _headers,
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int lectureId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/favorites/$lectureId'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<bool> clearFavorites() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/favorites'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  // Notifications Methods
  Future<List<AppNotification>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse('$baseUrl/notifications')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {..._headers, 'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        // Ensure proper UTF-8 decoding
        final bodyBytes = response.bodyBytes;
        final bodyString = utf8.decode(bodyBytes);
        final data = jsonDecode(bodyString);

        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((notificationJson) =>
                  AppNotification.fromJson(notificationJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<AppNotification?> getNotification(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: {..._headers, 'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        final bodyBytes = response.bodyBytes;
        final bodyString = utf8.decode(bodyBytes);
        final data = jsonDecode(bodyString);

        if (data['success'] == true && data['data'] != null) {
          return AppNotification.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching notification: $e');
      return null;
    }
  }

  Future<List<AppNotification>> getRecentNotifications({int days = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/recent?days=$days'),
        headers: {..._headers, 'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        final bodyBytes = response.bodyBytes;
        final bodyString = utf8.decode(bodyBytes);
        final data = jsonDecode(bodyString);

        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((notificationJson) =>
                  AppNotification.fromJson(notificationJson))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching recent notifications: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return {};
    } catch (e) {
      print('Error fetching notification stats: $e');
      return {};
    }
  }

  // Get unread notification count (for badge display)
  Future<int> getUnreadNotificationCount() async {
    try {
      // Try the new endpoint first
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/notifications/unread/count'),
          headers: _headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            return data['data']['unread_count'] ?? 0;
          }
        }
      } catch (e) {
        print('New unread endpoint not available, using fallback: $e');
      }

      // Fallback: Get all notifications and count unread on client side
      final notifications = await getNotifications(limit: 50);
      final readIds = await _getLocalReadNotificationIds();

      // Mark notifications as read based on local storage
      final unreadNotifications = notifications.where((n) {
        // If notification has backend read status, use it
        if (n.isRead) return false;
        // Otherwise check local storage
        return !readIds.contains(n.id);
      }).toList();

      return unreadNotifications.length;
    } catch (e) {
      print('Error fetching unread notification count: $e');
      return 0;
    }
  }

  // Get locally stored read notification IDs
  Future<Set<String>> _getLocalReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList('read_notification_ids') ?? [];
      return readIds.toSet();
    } catch (e) {
      print('Error getting local read notification IDs: $e');
      return <String>{};
    }
  }

  // Store read notification ID locally
  Future<void> _storeLocalReadNotificationId(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList('read_notification_ids') ?? [];
      if (!readIds.contains(notificationId)) {
        readIds.add(notificationId);
        await prefs.setStringList('read_notification_ids', readIds);
      }
    } catch (e) {
      print('Error storing local read notification ID: $e');
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] == true;
        if (success) {
          await _storeLocalReadNotificationId(notificationId);
        }
        return success;
      }
    } catch (e) {
      print('Error marking notification as read (endpoint not available): $e');
    }

    // Always store locally even if backend call fails
    await _storeLocalReadNotificationId(notificationId);
    return true;
  }

  // Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] == true;
        if (success) {
          // Get all current notifications and mark them locally
          final notifications = await getNotifications(limit: 100);
          for (final notification in notifications) {
            await _storeLocalReadNotificationId(notification.id);
          }
        }
        return success;
      }
    } catch (e) {
      print(
          'Error marking all notifications as read (endpoint not available): $e');
    }

    // Fallback: mark all current notifications as read locally
    try {
      final notifications = await getNotifications(limit: 100);
      for (final notification in notifications) {
        await _storeLocalReadNotificationId(notification.id);
      }
    } catch (e) {
      print('Error marking notifications as read locally: $e');
    }

    return true;
  }
}
