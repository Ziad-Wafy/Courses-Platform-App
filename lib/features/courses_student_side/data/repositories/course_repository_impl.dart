import '../data_sources/courses_remote_data_source.dart';
import '../models/course_model.dart';
import '../../domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CoursesRemoteDataSource remoteDataSource;

  CourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CourseModel>> getCourses() async {
    return await remoteDataSource.getCourses();
  }
}
