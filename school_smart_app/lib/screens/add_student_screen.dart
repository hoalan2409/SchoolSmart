import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/student.dart';
import '../models/grade.dart';
import '../services/api_service.dart';
import 'add_grade_screen.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({Key? key}) : super(key: key);
  
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  
  Grade? _selectedGrade;
  // String? _selectedSection; // Removed section field
  DateTime? _selectedDateOfBirth;
  List<File> _studentImages = []; // Multiple images for ML
  final ImagePicker _picker = ImagePicker();
  
  List<Grade> _availableGrades = [];
  bool _isLoadingGrades = true;
  
  @override
  void initState() {
    super.initState();
    _loadGrades();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGrades() async {
    try {
      setState(() {
        _isLoadingGrades = true;
      });
      
      // Load grades from API
      _availableGrades = await ApiService.getGrades();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading grades: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingGrades = false;
      });
    }
  }
  
  Future<void> _navigateToAddGrade() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGradeScreen()),
    );
    
    if (result != null && result is Grade) {
      // Refresh grades list
      await _loadGrades();
      
      // Auto-select the newly created grade
      setState(() {
        _selectedGrade = result;
        // _selectedSection = null; // Reset section
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grade "${result.name}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _studentImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _removeImage(int index) {
    setState(() {
      _studentImages.removeAt(index);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Student'),
        actions: [
          TextButton(
            onPressed: _saveStudent,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Photos Section for ML
              _buildSectionHeader('Student Photos (Required for Face Recognition ML)'),
              SizedBox(height: 16),
              
              // Image Grid
              if (_studentImages.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _studentImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _studentImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              
              SizedBox(height: 16),
              
              // Image Capture Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Add Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  if (_studentImages.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _studentImages.clear();
                        });
                      },
                      icon: Icon(Icons.delete_sweep),
                      label: Text('Clear All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 8),
              Text(
                'Add 3-5 clear face photos for accurate ML face recognition',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24),
              
              // Student Information Section
              _buildSectionHeader('Student Information'),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter student name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Grade Selection
              _isLoadingGrades
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Loading grades...'),
                          ],
                        ),
                      ),
                    )
                  : DropdownButtonFormField<Grade>(
                      value: _selectedGrade,
                      decoration: InputDecoration(
                        labelText: 'Grade *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: _availableGrades.map((Grade grade) {
                        return DropdownMenuItem<Grade>(
                          value: grade,
                          child: Text(grade.name),
                        );
                      }).toList(),
                      onChanged: (Grade? newValue) {
                        setState(() {
                          _selectedGrade = newValue;
                          // _selectedSection = null; // Reset section
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select grade';
                        }
                        return null;
                      },
                    ),
              
              SizedBox(height: 8),
              
              // Add Grade Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _navigateToAddGrade,
                    icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                    label: Text(
                      'Add New Grade',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDateOfBirth,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDateOfBirth != null
                              ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                              : 'Select Date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              
              SizedBox(height: 32),
              
              // Parent Information Section
              _buildSectionHeader('Parent Information'),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _parentNameController,
                      decoration: InputDecoration(
                        labelText: 'Parent Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _parentPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Parent Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              TextFormField(
                controller: _parentEmailController,
                decoration: InputDecoration(
                  labelText: 'Parent Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Save Student with ML Face Recognition',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }
  
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)), // 18 years ago
      firstDate: DateTime.now().subtract(Duration(days: 365 * 25)), // 25 years ago
      lastDate: DateTime.now().subtract(Duration(days: 365 * 5)), // 5 years ago
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }
  
  void _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      // Validate ML requirements
      if (_studentImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one photo for ML face recognition'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_studentImages.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least 3 photos for better ML accuracy'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_selectedGrade == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select grade'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Saving student with ML face recognition...'),
                ],
              ),
            );
          },
        );
        
        // Prepare date of birth string
        String? dateOfBirthString;
        if (_selectedDateOfBirth != null) {
          dateOfBirthString = _selectedDateOfBirth!.toIso8601String().split('T')[0];
        }
        
        // Call API service to upload photos and create student
        final student = await ApiService.createStudentWithPhotos(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          grade: _selectedGrade!.name,
          // section: _selectedSection!, // Removed section
          dateOfBirth: dateOfBirthString,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          parentName: _parentNameController.text.trim().isEmpty ? null : _parentNameController.text.trim(),
          parentPhone: _parentPhoneController.text.trim().isEmpty ? null : _parentPhoneController.text.trim(),
          parentEmail: _parentEmailController.text.trim().isEmpty ? null : _parentEmailController.text.trim(),
          photos: _studentImages,
        );
        
        // Hide loading indicator
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ${student.name} added successfully with ML face recognition!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back with student data
        Navigator.pop(context, student);
        
      } catch (e) {
        // Hide loading indicator
        Navigator.pop(context);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
