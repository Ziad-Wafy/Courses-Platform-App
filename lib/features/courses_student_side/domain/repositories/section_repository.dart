import '../../data/models/section_model.dart';

abstract class SectionRepository {
  Future<List<SectionModel>> getSections(String courseId);
}
