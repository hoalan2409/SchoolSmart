class Attendance {
  final int id;
  final int studentId;
  final String studentName;
  final DateTime timestamp;
  final bool isPresent;
  final String? notes;
  final String? markedBy;
  final String? location;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Attendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.timestamp,
    required this.isPresent,
    this.notes,
    this.markedBy,
    this.location,
    this.isSynced = false,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['student_id'],
      studentName: json['student_name'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isPresent: json['is_present'],
      notes: json['notes'],
      markedBy: json['marked_by'],
      location: json['location'],
      isSynced: json['is_synced'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'timestamp': timestamp.toIso8601String(),
      'is_present': isPresent,
      'notes': notes,
      'marked_by': markedBy,
      'location': location,
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  Attendance copyWith({
    int? id,
    int? studentId,
    String? studentName,
    DateTime? timestamp,
    bool? isPresent,
    String? notes,
    String? markedBy,
    String? location,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      timestamp: timestamp ?? this.timestamp,
      isPresent: isPresent ?? this.isPresent,
      notes: notes ?? this.notes,
      markedBy: markedBy ?? this.markedBy,
      location: location ?? this.location,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Attendance(id: $id, studentId: $studentId, studentName: $studentName, isPresent: $isPresent, timestamp: $timestamp)';
  }
}
