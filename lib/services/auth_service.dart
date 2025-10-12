import 'package:flutter/foundation.dart';

import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await _apiService.initialize();
    _isLoggedIn = await _apiService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email: email, password: password);

      if (result['success'] == true) {
        _isLoggedIn = true;
        _currentUser = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.register(
        username: username,
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        _isLoggedIn = true;
        _currentUser = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
