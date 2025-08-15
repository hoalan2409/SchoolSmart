import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentsProvider extends ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _students = await ApiService.getStudents();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudent(Map<String, dynamic> studentData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newStudent = await ApiService.createStudent(studentData);
      
      _students.add(newStudent);
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedStudent = await ApiService.updateStudent(id, studentData);
      
      final index = _students.indexWhere((student) => student.id == id);
      if (index != -1) {
        _students[index] = updatedStudent;
      }
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await ApiService.deleteStudent(id);
      
      _students.removeWhere((student) => student.id == id);
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
