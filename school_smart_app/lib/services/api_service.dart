import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  String? _authToken;
  
  ApiService() {
    _initializeDio();
    _loadAuthToken();
  }
  
  Future<void> _initializeDio() async {
    _dio = Dio();
    
    // Set base URL based on platform
    String baseUrl = AppConstants.baseUrl;
    
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: AppConstants.connectionTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: AppConstants.receiveTimeout);
    
    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        // Add common headers
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          await _refreshToken();
          // Retry the request
          final response = await _dio.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );
          handler.resolve(response);
          return;
        }
        handler.next(error);
      },
    ));
  }
  
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.authTokenKey);
  }
  
  Future<void> _saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
  }
  
  Future<bool> _refreshToken() async {
    try {
      final response = await _dio.post(ApiEndpoints.refreshToken);
      final newToken = response.data['access_token'];
      await _saveAuthToken(newToken);
      return true;
    } catch (e) {
      // Refresh failed, user needs to login again
      await _clearAuthToken();
      return false;
    }
  }
  
  Future<void> _clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
  }
  
  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(ApiEndpoints.login, data: {
        'username': username,
        'password': password,
      });
      
      final token = response.data['access_token'];
      await _saveAuthToken(token);
      
      return response.data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.userProfile);
      return response.data;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(ApiEndpoints.register, data: userData);
      return response.data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      if (_authToken != null) {
        await _dio.post(ApiEndpoints.logout);
      }
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _clearAuthToken();
    }
  }
  
  // Students
  Future<List<Student>> getStudents({int? page, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await _dio.get(ApiEndpoints.students, queryParameters: queryParams);
      
      if (response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => Student.fromJson(json))
            .toList();
      } else {
        return (response.data as List)
            .map((json) => Student.fromJson(json))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }
  
  Future<Student> getStudentById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.studentById.replaceAll('{id}', id.toString()));
      return Student.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load student: $e');
    }
  }
  
  Future<Student> createStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await _dio.post(ApiEndpoints.students, data: studentData);
      return Student.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }
  
  Future<Student> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.studentById.replaceAll('{id}', id.toString()),
        data: studentData,
      );
      return Student.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }
  
  Future<void> deleteStudent(int id) async {
    try {
      await _dio.delete(ApiEndpoints.studentById.replaceAll('{id}', id.toString()));
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }
  
  Future<String> uploadStudentPhoto(int studentId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imagePath),
      });
      
      final response = await _dio.post(
        ApiEndpoints.studentPhoto.replaceAll('{id}', studentId.toString()),
        data: formData,
      );
      
      return response.data['photo_url'];
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
  
  // Attendance
  Future<List<Attendance>> getAttendance({
    DateTime? date,
    int? studentId,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date.toIso8601String();
      if (studentId != null) queryParams['student_id'] = studentId;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await _dio.get(ApiEndpoints.attendance, queryParameters: queryParams);
      
      if (response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => Attendance.fromJson(json))
            .toList();
      } else {
        return (response.data as List)
            .map((json) => Attendance.fromJson(json))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }
  
  Future<Attendance> markAttendance(Map<String, dynamic> attendanceData) async {
    try {
      final response = await _dio.post(ApiEndpoints.attendance, data: attendanceData);
      return Attendance.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }
  
  Future<Attendance> updateAttendance(int id, Map<String, dynamic> attendanceData) async {
    try {
      final response = await _dio.put('${ApiEndpoints.attendance}/$id', data: attendanceData);
      return Attendance.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }
  
  // Face Recognition
  Future<Map<String, dynamic>> recognizeFace(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });
      
      final response = await _dio.post(ApiEndpoints.recognizeFace, data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Face recognition failed: $e');
    }
  }
  
  Future<bool> trainFace(int studentId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'student_id': studentId,
        'image': await MultipartFile.fromFile(imagePath),
      });
      
      await _dio.post(ApiEndpoints.trainFace, data: formData);
      return true;
    } catch (e) {
      throw Exception('Face training failed: $e');
    }
  }
  
  // Sync
  Future<Map<String, dynamic>> syncData() async {
    try {
      final response = await _dio.post(ApiEndpoints.sync);
      return response.data;
    } catch (e) {
      throw Exception('Sync failed: $e');
    }
  }
  
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final response = await _dio.get(ApiEndpoints.syncStatus);
      return response.data;
    } catch (e) {
      throw Exception('Failed to get sync status: $e');
    }
  }
  
  // Reports
  Future<Map<String, dynamic>> getAttendanceReport({
    DateTime? startDate,
    DateTime? endDate,
    String? grade,
    String? section,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (grade != null) queryParams['grade'] = grade;
      if (section != null) queryParams['section'] = section;
      
      final response = await _dio.get(ApiEndpoints.attendanceReport, queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load attendance report: $e');
    }
  }
  
  Future<Map<String, dynamic>> getStudentReport({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (studentId != null) queryParams['student_id'] = studentId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      final response = await _dio.get(ApiEndpoints.studentReport, queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load student report: $e');
    }
  }
}
