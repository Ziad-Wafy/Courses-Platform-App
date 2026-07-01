import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/domain/repositories/lesson_repository.dart';

class GetLessonsUseCase {
  final LessonRepository repository;

  GetLessonsUseCase(this.repository);

  Future<List<LessonModel>> call(
    String courseId,
    String sectionId,
  ) async {
    return await repository.getLessons(
      courseId,
      sectionId,
    );
  }
}