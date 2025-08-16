import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      // Use default language if loading fails
      _currentLocale = const Locale('en');
    }
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode != languageCode) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
      
      // Save to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
      } catch (e) {
        // Handle error silently
      }
    }
  }
  
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }
  
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'vi', 'name': 'Vietnamese', 'nativeName': 'Tiếng Việt'},
    ];
  }
}
