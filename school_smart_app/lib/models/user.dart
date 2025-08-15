class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? fullName;
  final String? phoneNumber;
  final String? profilePhoto;
  final DateTime? lastLogin;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.phoneNumber,
    this.profilePhoto,
    this.lastLogin,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      profilePhoto: json['profile_photo'],
      lastLogin: json['last_login'] != null 
          ? DateTime.tryParse(json['last_login']) ?? DateTime.now()
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_photo': profilePhoto,
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    String? fullName,
    String? phoneNumber,
    String? profilePhoto,
    DateTime? lastLogin,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role)';
  }
}
