import '../data_sources/courses_remote_data_source.dart';
import '../models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/domain/repositories/lesson_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  final CoursesRemoteDataSource remoteDataSource;

  LessonRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<LessonModel>> getLessons(
    String courseId,
    String sectionId,
  ) async {
    return await remoteDataSource.getLessons(
      courseId,
      sectionId,
    );
  }
}