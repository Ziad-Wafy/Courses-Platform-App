import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';

import '../repositories/course_repository.dart';

class CoursesUseCase {
  final CourseRepository repository;

  CoursesUseCase(this.repository);

  Future<List<CourseModel>> getCourses() async {
    return await repository.getCourses();
  }

  Future<void> courseEnroll(String courseId) async {
    await repository.enrollCourse(courseId);
  }

  Future<List<CourseModel>> getEnrolledCourses() async {
    return await repository.getEnrolledCourses();
  }
}
