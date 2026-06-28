import 'package:learning_management_system/features/courses_student_side/data/repositories/course_repository_impl.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';

class GetLessonsUseCase {
  final CourseRepositoryImpl repository;

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