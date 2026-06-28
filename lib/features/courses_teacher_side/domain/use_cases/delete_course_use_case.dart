import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class DeleteCourseUseCase {
  final TeacherCourseRepository repository;

  DeleteCourseUseCase(this.repository);

  Future<void> call(String courseId) async {
    await repository.deleteCourse(courseId);
  }
}
