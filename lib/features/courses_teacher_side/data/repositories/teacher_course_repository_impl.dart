import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/data/data_sources/teacher_courses_remote_data_source.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/repositories/teacher_course_repository.dart';

class TeacherCourseRepositoryImpl implements TeacherCourseRepository {
  final TeacherCoursesRemoteDataSource remoteDataSource;

  TeacherCourseRepositoryImpl(this.remoteDataSource);

  // ── Course ────────────────────────────────────────────────────────────────

  @override
  Future<List<CourseModel>> getTeacherCourses(String teacherId) async {
    return await remoteDataSource.getTeacherCourses(teacherId);
  }

  @override
  Future<void> addCourse(CourseModel course) async {
    await remoteDataSource.addCourse(course);
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    await remoteDataSource.updateCourse(course);
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await remoteDataSource.deleteCourse(courseId);
  }

  // ── Section ───────────────────────────────────────────────────────────────

  @override
  Future<void> addSection(String courseId, SectionModel section) async {
    await remoteDataSource.addSection(courseId, section);
  }

  @override
  Future<void> updateSection(String courseId, SectionModel section) async {
    await remoteDataSource.updateSection(courseId, section);
  }

  @override
  Future<void> deleteSection(String courseId, String sectionId) async {
    await remoteDataSource.deleteSection(courseId, sectionId);
  }

  // ── Lesson ────────────────────────────────────────────────────────────────

  @override
  Future<void> addLesson(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    await remoteDataSource.addLesson(courseId, sectionId, lesson);
  }

  @override
  Future<void> updateLesson(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    await remoteDataSource.updateLesson(courseId, sectionId, lesson);
  }

  @override
  Future<void> deleteLesson(
    String courseId,
    String sectionId,
    String lessonId,
  ) async {
    await remoteDataSource.deleteLesson(courseId, sectionId, lessonId);
  }
}
