class Student {
  final int id;
  final String studentCode;  // Thêm student code
  final String name;
  final String? email;  // Đổi thành optional
  final String? photoUrl;
  final String grade;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? address;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final DateTime createdAt;
  
  Student({
    required this.id,
    required this.studentCode,  // Thêm student code
    required this.name,
    this.email,  // Đổi thành optional
    this.photoUrl,
    required this.grade,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    required this.createdAt,
  });
  
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentCode: json['student_code'] ?? '',  // Parse student code
      name: json['full_name'] ?? json['name'],
      email: json['email'],  // Có thể null
      photoUrl: json['photo_path'] ?? json['photo_url'],
      grade: json['grade'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      phoneNumber: json['phone'],
      address: json['address'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_code': studentCode,  // Thêm student code
      'full_name': name,
      'email': email,  // Có thể null
      'photo_path': photoUrl,
      'grade': grade,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone': phoneNumber,
      'address': address,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  Student copyWith({
    int? id,
    String? studentCode,  // Thêm student code
    String? name,
    String? email,
    String? photoUrl,
    String? grade,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? address,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,  // Thêm student code
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      grade: grade ?? this.grade,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Student(id: $id, studentCode: $studentCode, name: $name, email: $email, grade: $grade)';
  }
}
