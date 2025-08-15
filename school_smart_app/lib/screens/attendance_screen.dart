import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/attendance.dart';

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

  final List<String> _grades = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];

  
  // Mock data - replace with actual data from database
  List<Student> _students = [
    Student(
      id: 1,
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@example.com',
      grade: 'Grade 10',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 2,
      name: 'Trần Thị B',
      email: 'tranthib@example.com',
      grade: 'Grade 10',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 3,
      name: 'Lê Văn C',
      email: 'levanc@example.com',
      grade: 'Grade 10',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 4,
      name: 'Phạm Thị D',
      email: 'phamthid@example.com',
      grade: 'Grade 10',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 5,
      name: 'Hoàng Văn E',
      email: 'hoangvane@example.com',
      grade: 'Grade 10',
      createdAt: DateTime.now(),
    ),
  ];
  
  final Map<int, bool> _attendanceMap = {};
  
  @override
  void initState() {
    super.initState();
    _selectedGrade = _grades[9]; // Grade 10
    _filterStudents();
  }
  
  void _initializeAttendance() {
    _attendanceMap.clear();
    for (var student in _filteredStudents) {
      _attendanceMap[student.id] = true; // Default to present
    }
  }

  void _loadStudents() {
    setState(() {
      _filteredStudents = _students;
    });
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
                child: DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: InputDecoration(
                    labelText: 'Grade',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _grades.map((String grade) {
                    return DropdownMenuItem<String>(
                      value: grade,
                      child: Text(grade),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGrade = newValue;
                      _filterStudents();
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              // Removed Section Dropdown - section field no longer exists
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttendanceSummary() {
    int totalStudents = _students.length;
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
