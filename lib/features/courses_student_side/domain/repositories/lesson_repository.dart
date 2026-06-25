import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';

abstract class LessonRepository {
  Future<List<LessonModel>> getLessons(String courseId, String sectionId);
}
