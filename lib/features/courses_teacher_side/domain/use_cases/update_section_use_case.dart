import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class UpdateSectionUseCase {
  final TeacherCourseRepository repository;

  UpdateSectionUseCase(this.repository);

  Future<void> call(String courseId, SectionModel section) async {
    await repository.updateSection(courseId, section);
  }
}
