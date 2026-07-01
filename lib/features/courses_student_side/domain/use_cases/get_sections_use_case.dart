import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_student_side/domain/repositories/section_repository.dart';

class GetSectionsUseCase {
  final SectionRepository repository;

  GetSectionsUseCase(this.repository);

  Future<List<SectionModel>> call(
    String courseId,
  ) async {
    return await repository.getSections(
      courseId,
    );
  }
}