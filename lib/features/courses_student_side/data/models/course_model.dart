import 'package:learning_management_system/features/courses_student_side/domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.instructor,
    required super.image,
    required super.description,
    required super.studentsCount,
    required super.rating,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json, String id) {
    return CourseModel(
      id: id,
      title: json['title'] ?? '',
      instructor: json['instructor'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      studentsCount: json['studentsCount'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'instructor': instructor,
      'image': image,
      'description': description,
      'studentsCount': studentsCount,
      'rating': rating,
    };
  }
}
