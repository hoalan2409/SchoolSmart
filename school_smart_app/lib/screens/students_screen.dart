import 'package:flutter/material.dart';
import '../models/student.dart';
import 'add_student_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);
  
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGrade;
  String? _selectedSection;
  String _searchQuery = '';
  
  final List<String> _grades = ['All Grades', 'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
  final List<String> _sections = ['All Sections', 'A', 'B', 'C', 'D', 'E'];
  
  // Mock data - replace with actual data from database
  List<Student> _allStudents = [
    Student(
      id: 1,
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@example.com',
      grade: 'Grade 10',
      section: 'A',
      phoneNumber: '0123456789',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 2,
      name: 'Trần Thị B',
      email: 'tranthib@example.com',
      grade: 'Grade 10',
      section: 'A',
      phoneNumber: '0123456790',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 3,
      name: 'Lê Văn C',
      email: 'levanc@example.com',
      grade: 'Grade 10',
      section: 'B',
      phoneNumber: '0123456791',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 4,
      name: 'Phạm Thị D',
      email: 'phamthid@example.com',
      grade: 'Grade 11',
      section: 'A',
      phoneNumber: '0123456792',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 5,
      name: 'Hoàng Văn E',
      email: 'hoangvane@example.com',
      grade: 'Grade 11',
      section: 'B',
      phoneNumber: '0123456793',
      createdAt: DateTime.now(),
    ),
    Student(
      id: 6,
      name: 'Vũ Thị F',
      email: 'vuthif@example.com',
      grade: 'Grade 9',
      section: 'A',
      phoneNumber: '0123456794',
      createdAt: DateTime.now(),
    ),
  ];
  
  List<Student> _filteredStudents = [];
  
  @override
  void initState() {
    super.initState();
    _selectedGrade = _grades[0]; // All Grades
    _selectedSection = _sections[0]; // All Sections
    _filteredStudents = List.from(_allStudents);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewStudent,
            tooltip: 'Add New Student',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          _buildSearchAndFilters(),
          
          // Students Count
          _buildStudentsCount(),
          
          // Students List
          Expanded(
            child: _buildStudentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewStudent,
        child: Icon(Icons.add),
        tooltip: 'Add New Student',
      ),
    );
  }
  
  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search students by name or email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterStudents();
              });
            },
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
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSection,
                  decoration: InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _sections.map((String section) {
                    return DropdownMenuItem<String>(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSection = newValue;
                      _filterStudents();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentsCount() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.people, color: Colors.grey[600], size: 20),
          SizedBox(width: 8),
          Text(
            '${_filteredStudents.length} students found',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          TextButton.icon(
            onPressed: _filterStudents,
            icon: Icon(Icons.refresh, size: 16),
            label: Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
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
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addNewStudent,
              icon: Icon(Icons.add),
              label: Text('Add First Student'),
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
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student.grade} - Section ${student.section}',
                  style: TextStyle(fontSize: 12),
                ),
                if (student.phoneNumber != null)
                  Text(
                    '📞 ${student.phoneNumber}',
                    style: TextStyle(fontSize: 12),
                  ),
                Text(
                  '📧 ${student.email}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) => _handleStudentAction(value, student),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'attendance',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 18),
                      SizedBox(width: 8),
                      Text('View Attendance'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _viewStudentDetails(student),
          ),
        );
      },
    );
  }
  
  void _filterStudents() {
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        // Search filter
        bool matchesSearch = _searchQuery.isEmpty ||
            student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            student.email.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Grade filter
        bool matchesGrade = _selectedGrade == 'All Grades' ||
            student.grade == _selectedGrade;
        
        // Section filter
        bool matchesSection = _selectedSection == 'All Sections' ||
            student.section == _selectedSection;
        
        return matchesSearch && matchesGrade && matchesSection;
      }).toList();
    });
  }
  
  void _addNewStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddStudentScreen()),
    );
    
    if (result != null && result is Student && mounted) {
      setState(() {
        _allStudents.add(result);
        _filterStudents();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  void _viewStudentDetails(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', student.name),
              _buildDetailRow('Email', student.email),
              _buildDetailRow('Grade', student.grade ?? 'N/A'),
              _buildDetailRow('Section', student.section ?? 'N/A'),
              _buildDetailRow('Phone', student.phoneNumber ?? 'N/A'),
              _buildDetailRow('Address', student.address ?? 'N/A'),
              _buildDetailRow('Date of Birth', student.dateOfBirth != null 
                  ? '${student.dateOfBirth!.day}/${student.dateOfBirth!.month}/${student.dateOfBirth!.year}'
                  : 'N/A'),
              _buildDetailRow('Parent Name', student.parentName ?? 'N/A'),
              _buildDetailRow('Parent Phone', student.parentPhone ?? 'N/A'),
              _buildDetailRow('Parent Email', student.parentEmail ?? 'N/A'),
              _buildDetailRow('Status', student.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Created', '${student.createdAt.day}/${student.createdAt.month}/${student.createdAt.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to edit screen
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleStudentAction(String action, Student student) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit functionality coming soon!')),
        );
        break;
      case 'view':
        _viewStudentDetails(student);
        break;
      case 'attendance':
        // TODO: Navigate to attendance screen for this student
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance view coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(student);
        break;
    }
  }
  
  void _showDeleteConfirmation(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allStudents.removeWhere((s) => s.id == student.id);
                _filterStudents();
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Student deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
