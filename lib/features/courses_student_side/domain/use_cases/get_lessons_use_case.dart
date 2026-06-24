import '../../data/models/lesson_model.dart';
import '../repositories/lesson_repository.dart';

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