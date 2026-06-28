import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class DeleteSectionUseCase {
  final TeacherCourseRepository repository;

  DeleteSectionUseCase(this.repository);

  Future<void> call(String courseId, String sectionId) async {
    await repository.deleteSection(courseId, sectionId);
  }
}
