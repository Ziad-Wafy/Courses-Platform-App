class ProfileEntity {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'Student' or 'Teacher'
  final String? avatarUrl;
  final String? bio;
  final String? phoneNumber;
  final StudentStats? studentStats;
  final TeacherStats? teacherStats;

  const ProfileEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.phoneNumber,
    this.studentStats,
    this.teacherStats,
  });

  bool get isStudent => role == 'Student';
  bool get isTeacher => role == 'Teacher';

  ProfileEntity copyWith({
    String? fullName,
    String? email,
    String? role,
    String? avatarUrl,
    String? bio,
    String? phoneNumber,
    StudentStats? studentStats,
    TeacherStats? teacherStats,
  }) {
    return ProfileEntity(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentStats: studentStats ?? this.studentStats,
      teacherStats: teacherStats ?? this.teacherStats,
    );
  }
}

class StudentStats {
  final int enrolled;
  final int completed;
  final int certificates;
  final double avgScore;

  const StudentStats({
    required this.enrolled,
    required this.completed,
    required this.certificates,
    required this.avgScore,
  });
}

class TeacherStats {
  final int courses;
  final int students;
  final double rating;
  final int issued;

  const TeacherStats({
    required this.courses,
    required this.students,
    required this.rating,
    required this.issued,
  });
}