class Student {
  final int id;
  final String name;
  final String email;
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
    required this.name,
    required this.email,
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
      name: json['full_name'] ?? json['name'],
      email: json['email'],
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
      'full_name': name,
      'email': email,
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
    return 'Student(id: $id, name: $name, email: $email, grade: $grade)';
  }
}
