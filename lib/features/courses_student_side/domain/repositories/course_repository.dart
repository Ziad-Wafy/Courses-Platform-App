import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> getCourses();
}