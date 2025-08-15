import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentsProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;
  
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _students = await ApiService().getStudents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createStudent(Map<String, dynamic> studentData) async {
    try {
      final newStudent = await ApiService().createStudent(studentData);
      _students.add(newStudent);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final updatedStudent = await ApiService().updateStudent(id, studentData);
      final index = _students.indexWhere((s) => s.id == id);
      if (index != -1) {
        _students[index] = updatedStudent;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteStudent(int id) async {
    try {
      await ApiService().deleteStudent(id);
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
