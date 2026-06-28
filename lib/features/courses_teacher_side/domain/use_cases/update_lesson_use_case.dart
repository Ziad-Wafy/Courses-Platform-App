import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class UpdateLessonUseCase {
  final TeacherCourseRepository repository;

  UpdateLessonUseCase(this.repository);

  Future<void> call(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    await repository.updateLesson(courseId, sectionId, lesson);
  }
}
