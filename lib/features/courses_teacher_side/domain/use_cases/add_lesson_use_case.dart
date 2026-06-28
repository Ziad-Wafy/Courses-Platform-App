import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class AddLessonUseCase {
  final TeacherCourseRepository repository;

  AddLessonUseCase(this.repository);

  Future<void> call(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    await repository.addLesson(courseId, sectionId, lesson);
  }
}
