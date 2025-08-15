class Student {
  final int id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? grade;
  final String? section;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? address;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Student({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.grade,
    this.section,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photo_url'],
      grade: json['grade'],
      section: json['section'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      phoneNumber: json['phone_number'],
      address: json['address'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'grade': grade,
      'section': section,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'address': address,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  Student copyWith({
    int? id,
    String? name,
    String? email,
    String? photoUrl,
    String? grade,
    String? section,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? address,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return 'Student(id: $id, name: $name, email: $email, grade: $grade, section: $section)';
  }
}
