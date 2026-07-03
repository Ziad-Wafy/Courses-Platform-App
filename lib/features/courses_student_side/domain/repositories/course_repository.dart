import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';

import '../../data/models/course_model.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> getCourses();

  Future<List<SectionModel>> getSections(String courseId);

  Future<List<LessonModel>> getLessons(String courseId, String sectionId);

  Future<void> enrollCourse(String courseId);

  Future<List<CourseModel>> getEnrolledCourses();
}