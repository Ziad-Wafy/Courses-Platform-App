import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class GetTeacherCoursesUseCase {
  final TeacherCourseRepository repository;

  GetTeacherCoursesUseCase(this.repository);

  Future<List<CourseModel>> call(String teacherId) {
    return repository.getTeacherCourses(teacherId);
  }
}
