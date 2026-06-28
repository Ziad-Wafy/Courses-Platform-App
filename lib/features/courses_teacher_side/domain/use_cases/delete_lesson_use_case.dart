import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class DeleteLessonUseCase {
  final TeacherCourseRepository repository;

  DeleteLessonUseCase(this.repository);

  Future<void> call(
    String courseId,
    String sectionId,
    String lessonId,
  ) async {
    await repository.deleteLesson(courseId, sectionId, lessonId);
  }
}
