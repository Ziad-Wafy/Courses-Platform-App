import '../data_sources/courses_remote_data_source.dart';
import '../models/section_model.dart';
import 'package:learning_management_system/features/courses_student_side/domain/repositories/section_repository.dart';

class SectionRepositoryImpl implements SectionRepository {
  final CoursesRemoteDataSource remoteDataSource;

  SectionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SectionModel>> getSections(String courseId) async {
    return await remoteDataSource.getSections(courseId);
  }
}
