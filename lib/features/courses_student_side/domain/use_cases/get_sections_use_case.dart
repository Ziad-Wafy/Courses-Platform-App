import '../../data/models/section_model.dart';
import '../repositories/section_repository.dart';

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