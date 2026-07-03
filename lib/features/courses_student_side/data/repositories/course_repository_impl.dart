import 'package:learning_management_system/features/courses_student_side/data/data_sources/courses_remoter_data.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';

import '../models/course_model.dart';
import '../../domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CoursesRemoteDataSource remoteDataSource;

  CourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CourseModel>> getCourses() async {
    return await remoteDataSource.getCourses();
  }

  @override
  Future<List<SectionModel>> getSections(String courseId) async {
    return await remoteDataSource.getSections(courseId);
  }

  @override
  Future<List<LessonModel>> getLessons(
    String courseId,
    String sectionId,
  ) async {
    return await remoteDataSource.getLessons(courseId, sectionId);
  }

  @override
  Future<List<CourseModel>> getEnrolledCourses() async {
    return await remoteDataSource.getEnrolledCourses();
  }

  @override
  Future<void> enrollCourse(String courseId) async {
    await remoteDataSource.enrollCourse(courseId);
  }
}
