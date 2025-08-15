import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get token => _token;
  
  AuthProvider() {
    _loadStoredAuth();
  }
  
  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.authTokenKey);
    // Load user data if token exists
  }
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService().login(username, password);
      
      // Backend returns TokenResponse, not User data
      _token = response['access_token'];
      
      // Create a minimal User object from username (we'll get full data later)
      _user = User(
        id: 0, // Temporary ID, will be updated when we fetch user profile
        username: username,
        email: '', // Will be fetched later
        role: 'user', // Default role, will be updated later
        fullName: username, // Use username as display name for now
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      // Store token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, _token!);
      
      // Fetch full user profile
      await _fetchUserProfile();
      
      return true;
    } catch (e) {
      _error = e.toString();
      print('Login error: $e'); // Debug log
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchUserProfile() async {
    try {
      final userData = await ApiService().getUserProfile();
      _user = User.fromJson(userData);
      notifyListeners();
    } catch (e) {
      // If profile fetch fails, keep the minimal user object
      print('Failed to fetch user profile: $e');
      // Don't throw error, just log it
    }
  }
  
  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService().register(userData);
      // Registration successful, user can now login
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    _user = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
