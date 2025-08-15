import 'package:dio/dio.dart';
import 'dart:io';
import '../models/student.dart';
import '../models/grade.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator localhost
  static final Dio _dio = Dio();
  
  static void initialize() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }
  
  /// Upload student with multiple photos for ML face recognition
  static Future<Student> createStudentWithPhotos({
    required String name,
    String? email,  // Đổi thành optional
    required String grade,
    String? dateOfBirth,
    String? phone,
    String? address,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    required List<File> photos,
  }) async {
    try {
      // Create FormData for multipart upload
      FormData formData = FormData.fromMap({
        'name': name,
        'grade': grade,
        if (email != null && email.isNotEmpty) 'email': email,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (parentName != null) 'parent_name': parentName,
        if (parentPhone != null) 'parent_phone': parentPhone,
        if (parentEmail != null) 'parent_email': parentEmail,
      });
      
      // Add photos to FormData
      for (int i = 0; i < photos.length; i++) {
        String fileName = 'photo_$i.jpg';
        formData.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              photos[i].path,
              filename: fileName,
            ),
          ),
        );
      }
      
      // Make API call
      Response response = await _dio.post(
        '/students/with-photos',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response and create Student object
        Map<String, dynamic> data = response.data;
        return Student(
          id: data['id'],
          studentCode: data['student_code'] ?? '',
          name: data['full_name'],
          email: data['email'],
          photoUrl: data['photo_path'],
          grade: data['grade'],
          dateOfBirth: data['date_of_birth'] != null 
              ? DateTime.parse(data['date_of_birth']) 
              : null,
          phoneNumber: data['phone'],
          address: data['address'],
          parentName: data['parent_name'],
          parentPhone: data['parent_phone'],
          parentEmail: data['parent_email'],
          createdAt: DateTime.parse(data['created_at']),
        );
      } else {
        throw Exception('Failed to create student: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        // Request timeout
        throw Exception('Request timeout. Please check your connection.');
      } else {
        // Something else happened
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Get list of students
  static Future<List<Student>> getStudents({
    int skip = 0,
    int limit = 100,
    String? grade,
    String? section,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'skip': skip,
        'limit': limit,
      };
      
      if (grade != null) queryParams['grade'] = grade;
      if (section != null) queryParams['section'] = section;
      
      Response response = await _dio.get(
        '/students',
        queryParameters: queryParams,
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch students: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Get student by ID
  static Future<Student> getStudent(int studentId) async {
    try {
      Response response = await _dio.get(
        '/students/$studentId',
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return Student.fromJson(data);
      } else {
        throw Exception('Failed to fetch student: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Get student by student code
  static Future<Student> getStudentByCode(String studentCode) async {
    try {
      Response response = await _dio.get(
        '/students/code/$studentCode',
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return Student.fromJson(data);
      } else {
        throw Exception('Failed to fetch student: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Update student information
  static Future<Student> updateStudent(int studentId, Map<String, dynamic> updateData) async {
    try {
      Response response = await _dio.put(
        '/students/$studentId',
        data: updateData,
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return Student.fromJson(data);
      } else {
        throw Exception('Failed to update student: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Delete student
  static Future<bool> deleteStudent(int studentId) async {
    try {
      Response response = await _dio.delete(
        '/students/$studentId',
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return response.statusCode == 200;
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Upload additional photos for existing student
  static Future<Map<String, dynamic>> uploadStudentPhotos(
    int studentId,
    List<File> photos,
  ) async {
    try {
      FormData formData = FormData();
      
      // Add photos to FormData
      for (int i = 0; i < photos.length; i++) {
        String fileName = 'photo_$i.jpg';
        formData.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              photos[i].path,
              filename: fileName,
            ),
          ),
        );
      }
      
      Response response = await _dio.post(
        '/students/$studentId/upload-photos',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to upload photos: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Test connection to backend
  static Future<bool> testConnection() async {
    try {
      Response response = await _dio.get(
        '/health',
        options: Options(
          sendTimeout: Duration(seconds: 5),
          receiveTimeout: Duration(seconds: 5),
        ),
      );
      
      return response.statusCode == 200;
      
    } catch (e) {
      print('Backend connection test failed: $e');
      return false;
    }
  }
  
  // ==================== GRADE MANAGEMENT ====================
  
  /// Get list of grades
  static Future<List<Grade>> getGrades({
    int skip = 0,
    int limit = 100,
    bool activeOnly = true,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'skip': skip,
        'limit': limit,
        'active_only': activeOnly,
      };
      
      Response response = await _dio.get(
        '/grades/',
        queryParameters: queryParams,
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Grade.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch grades: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Create new grade
  static Future<Grade> createGrade(Map<String, dynamic> gradeData) async {
    try {
      Response response = await _dio.post(
        '/grades/',
        data: gradeData,
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = response.data;
        return Grade.fromJson(data);
      } else {
        throw Exception('Failed to create grade: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Update existing grade
  static Future<Grade> updateGrade(int gradeId, Map<String, dynamic> updateData) async {
    try {
      Response response = await _dio.put(
        '/grades/$gradeId/',
        data: updateData,
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return Grade.fromJson(data);
      } else {
        throw Exception('Failed to update grade: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Delete grade (soft delete)
  static Future<bool> deleteGrade(int gradeId) async {
    try {
      Response response = await _dio.delete(
        '/grades/$gradeId/',
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return response.statusCode == 200;
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Get grade by name
  static Future<Grade?> getGradeByName(String gradeName) async {
    try {
      Response response = await _dio.get(
        '/grades/name/$gradeName',
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return Grade.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Grade not found
      } else {
        throw Exception('Failed to fetch grade: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 404) {
          return null; // Grade not found
        }
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  // ==================== AUTHENTICATION (for providers) ====================
  
  /// Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      Response response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      Response response = await _dio.get(
        '/auth/profile',
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Register user
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      Response response = await _dio.post(
        '/auth/register',
        data: userData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  // ==================== OLD METHODS (for backward compatibility) ====================
  
  /// Create student (old method for providers)
  static Future<Student> createStudent(Map<String, dynamic> studentData) async {
    try {
      Response response = await _dio.post(
        '/students',
        data: studentData,
        options: Options(
          headers: {
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = response.data;
        return Student.fromJson(data);
      } else {
        throw Exception('Failed to create student: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null && e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else {
        throw Exception('Request failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
