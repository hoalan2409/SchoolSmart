import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/grade.dart'; // Add Grade model import
import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);
  
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedGrade;
  DateTime _selectedDate = DateTime.now();
  List<Student> _filteredStudents = [];
  bool _isLoading = false;
  String? _error;

  // Replace hardcoded grades with dynamic list from database
  List<Grade> _availableGrades = [];
  bool _isLoadingGrades = true;
  
  // Real data from API
  List<Student> _students = [];
  
  final Map<int, bool> _attendanceMap = {};
  
  @override
  void initState() {
    super.initState();
    _loadGrades(); // Load grades first
    _loadStudents();
  }
  
  // Load grades from database
  Future<void> _loadGrades() async {
    try {
      setState(() {
        _isLoadingGrades = true;
      });
      
      final grades = await ApiService.getGrades(activeOnly: true);
      setState(() {
        _availableGrades = grades;
        _isLoadingGrades = false;
        // Set default selection to first grade if available
        if (grades.isNotEmpty) {
          _selectedGrade = grades.first.name;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingGrades = false;
        _error = 'Failed to load grades: $e';
      });
    }
  }
  
  void _initializeAttendance() {
    _attendanceMap.clear();
    for (var student in _filteredStudents) {
      _attendanceMap[student.id] = true; // Default to present
    }
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final students = await ApiService.getStudents();
      setState(() {
        _students = students;
        _filteredStudents = List.from(students);
        _isLoading = false;
      });
      _initializeAttendance();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterStudents() {
    setState(() {
      _filteredStudents = _students.where((student) {
        bool gradeMatch = _selectedGrade == null || student.grade == _selectedGrade;
        return gradeMatch;
      }).toList();
      _initializeAttendance();
    });
  }

  void _onGradeChanged(String? newGrade) {
    setState(() {
      _selectedGrade = newGrade;
      _filterStudents();
    });
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _filterStudents();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveAttendance,
            tooltip: 'Save Attendance',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters and Date Selection
          _buildFiltersSection(),
          
          // Attendance Summary
          _buildAttendanceSummary(),
          
          // Students List
          Expanded(
            child: _buildStudentsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Date Selection
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Date: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Grade and Section Filters
          Row(
            children: [
              Expanded(
                child: _buildGradeFilter(),
              ),
              SizedBox(width: 16),
              // Removed Section Dropdown - section field no longer exists
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGradeFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedGrade,
      decoration: InputDecoration(
        labelText: 'Grade',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _availableGrades.map((Grade grade) {
        return DropdownMenuItem<String>(
          value: grade.name,
          child: Text(grade.name),
        );
      }).toList(),
      onChanged: _onGradeChanged,
    );
  }
  
  Widget _buildAttendanceSummary() {
    int totalStudents = _filteredStudents.length;
    int presentCount = _attendanceMap.values.where((isPresent) => isPresent).length;
    int absentCount = totalStudents - presentCount;
    double attendanceRate = totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total',
              totalStudents.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Present',
              presentCount.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Absent',
              absentCount.toString(),
              Icons.cancel,
              Colors.red,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Rate',
              '${attendanceRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStudentsList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading students...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16),
            Text(
              'Error loading students',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[600],
              ),
            ),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadStudents,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Please select a different grade or section',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        final isPresent = _attendanceMap[student.id] ?? true;
        
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPresent ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isPresent ? Icons.person : Icons.person_off,
                color: isPresent ? Colors.green[600] : Colors.red[600],
              ),
            ),
            title: Text(
              student.name,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${student.grade}',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Present Button
                InkWell(
                  onTap: () => _toggleAttendance(student.id, true),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPresent ? Colors.green : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Present',
                      style: TextStyle(
                        color: isPresent ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Absent Button
                InkWell(
                  onTap: () => _toggleAttendance(student.id, false),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: !isPresent ? Colors.red : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Absent',
                      style: TextStyle(
                        color: !isPresent ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _toggleAttendance(int studentId, bool isPresent) {
    setState(() {
      _attendanceMap[studentId] = isPresent;
    });
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // TODO: Load attendance data for selected date
    }
  }
  
  void _saveAttendance() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      // Create attendance records
      List<Attendance> attendanceRecords = [];
      for (var student in _students) {
        final isPresent = _attendanceMap[student.id] ?? true;
        attendanceRecords.add(Attendance(
          id: DateTime.now().millisecondsSinceEpoch + student.id,
          studentId: student.id,
          studentName: student.name,
          timestamp: _selectedDate,
          isPresent: isPresent,
          markedBy: 'Teacher', // TODO: Get from auth
          location: 'Classroom',
          createdAt: DateTime.now(),
        ));
      }
      
      // TODO: Save to database/API
      print('Saving ${attendanceRecords.length} attendance records');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
