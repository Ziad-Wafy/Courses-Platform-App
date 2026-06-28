import 'package:learning_management_system/features/courses_student_side/data/repositories/course_repository_impl.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';

class GetSectionsUseCase {
  final CourseRepositoryImpl repository;

  GetSectionsUseCase(this.repository);

  Future<List<SectionModel>> call(
    String courseId,
  ) async {
    return await repository.getSections(
      courseId,
    );
  }
}