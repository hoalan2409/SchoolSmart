import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/grade.dart'; // Add Grade model import
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.attendanceManagement),
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),
          
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
  
  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedGrade,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.grade,
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
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  _onDateChanged(date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.selectDate,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttendanceSummary() {
    final totalStudents = _filteredStudents.length;
    final presentCount = _attendanceMap.values.where((isPresent) => isPresent).length;
    final absentCount = totalStudents - presentCount;
    final attendanceRate = totalStudents > 0 ? (presentCount / totalStudents * 100).toStringAsFixed(1) : '0.0';
    
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.attendanceSummary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  AppLocalizations.of(context)!.totalStudents,
                  totalStudents.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  AppLocalizations.of(context)!.presentCount,
                  presentCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  AppLocalizations.of(context)!.absentCount,
                  absentCount.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  AppLocalizations.of(context)!.attendanceRate,
                  '$attendanceRate%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
              AppLocalizations.of(context)!.loadingStudents,
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
              AppLocalizations.of(context)!.errorLoadingStudents,
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
              label: Text(AppLocalizations.of(context)!.retry),
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
              AppLocalizations.of(context)!.noStudentsFound,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            Text(
              AppLocalizations.of(context)!.tryAdjustingSearch,
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
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                student.name.split(' ').last[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
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
                // Present/Absent Toggle
                Switch(
                  value: isPresent,
                  onChanged: (value) {
                    setState(() {
                      _attendanceMap[student.id] = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  isPresent 
                    ? AppLocalizations.of(context)!.present
                    : AppLocalizations.of(context)!.absent,
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
