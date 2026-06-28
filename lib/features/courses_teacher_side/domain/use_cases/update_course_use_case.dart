import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class UpdateCourseUseCase {
  final TeacherCourseRepository repository;

  UpdateCourseUseCase(this.repository);

  Future<void> call(CourseModel course) async {
    await repository.updateCourse(course);
  }
}
