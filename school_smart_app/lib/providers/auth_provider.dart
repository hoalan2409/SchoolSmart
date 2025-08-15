import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _authToken;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get authToken => _authToken;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.login(username, password);
      
      if (response['access_token'] != null) {
        _authToken = response['access_token'];
        _isAuthenticated = true;
        
        // Get user profile
        await _getUserProfile();
        
        return true;
      } else {
        _error = 'Login failed: Invalid response';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _error = 'Login failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getUserProfile() async {
    try {
      final userData = await ApiService.getUserProfile();
      
      if (userData != null) {
        _user = userData;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to fetch user profile: $e');
      // Don't fail login if profile fetch fails
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await ApiService.register(userData);
      
      _error = null;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _authToken = null;
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
