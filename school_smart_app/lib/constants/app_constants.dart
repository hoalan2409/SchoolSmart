class AppConstants {
  // App Info
  static const String appName = 'SchoolSmart';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android Emulator
  static const String localBaseUrl = 'http://localhost:8000/api/v1'; // iOS Simulator
  static const String productionBaseUrl = 'https://your-production-api.com/api/v1';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Quality
  static const int imageQuality = 80;
  static const double maxImageWidth = 1024.0;
  static const double maxImageHeight = 1024.0;
  
  // Face Recognition
  static const double faceDetectionConfidence = 0.8;
  static const int maxFacesPerImage = 10;
  
  // Attendance
  static const int attendanceSyncInterval = 300000; // 5 minutes
  static const int maxOfflineRecords = 1000;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String permissionDenied = 'Permission denied. Please grant required permissions.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logout successful!';
  static const String saveSuccess = 'Data saved successfully!';
  static const String deleteSuccess = 'Data deleted successfully!';
  static const String syncSuccess = 'Data synchronized successfully!';
}

class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Users
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  
  // Students
  static const String students = '/students';
  static const String studentById = '/students/{id}';
  static const String studentPhoto = '/students/{id}/photo';
  
  // Attendance
  static const String attendance = '/attendance';
  static const String attendanceByDate = '/attendance/date/{date}';
  static const String attendanceByStudent = '/attendance/student/{id}';
  
  // Face Recognition
  static const String faceRecognition = '/face-recognition';
  static const String recognizeFace = '/face-recognition/recognize';
  static const String trainFace = '/face-recognition/train';
  
  // Sync
  static const String sync = '/sync';
  static const String syncStatus = '/sync/status';
  
  // Reports
  static const String reports = '/reports';
  static const String attendanceReport = '/reports/attendance';
  static const String studentReport = '/reports/students';
}

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String students = '/students';
  static const String attendance = '/attendance';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
