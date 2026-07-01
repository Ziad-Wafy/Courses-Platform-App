import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';

abstract class SectionRepository {
  Future<List<SectionModel>> getSections(String courseId);
}
