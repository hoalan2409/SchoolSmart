import 'package:flutter/material.dart';
import '../models/grade.dart';
import '../services/api_service.dart';

class AddGradeScreen extends StatefulWidget {
  final Grade? grade; // If editing existing grade
  
  const AddGradeScreen({Key? key, this.grade}) : super(key: key);
  
  @override
  _AddGradeScreenState createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.grade != null;
    
    if (_isEditing) {
      _nameController.text = widget.grade!.name;
      _descriptionController.text = widget.grade!.description ?? '';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  

  
  Future<void> _saveGrade() async {
    if (_formKey.currentState!.validate()) {

      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Prepare grade data
        Map<String, dynamic> gradeData = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          'is_active': true,
        };
        
        Grade grade;
        
        if (_isEditing) {
          // Update existing grade
          grade = await ApiService.updateGrade(widget.grade!.id, gradeData);
        } else {
          // Create new grade
          grade = await ApiService.createGrade(gradeData);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Grade updated successfully!' : 'Grade created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, grade);
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Grade' : 'Add New Grade'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveGrade,
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grade Information Section
                    _buildSectionHeader('Grade Information'),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Grade Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                        hintText: 'e.g., Grade 1, Class 6',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter grade name';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'e.g., First year of primary school',
                      ),
                      maxLines: 2,
                    ),
                    

                    

                    
                    SizedBox(height: 16),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveGrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Saving...'),
                                ],
                              )
                            : Text(
                                _isEditing ? 'Update Grade' : 'Create Grade',
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
}
