import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';

abstract class TeacherCourseRepository {
  Future<void> addCourse(CourseModel course);
  Future<void> updateCourse(CourseModel course);
  Future<void> deleteCourse(String courseId);

  Future<void> addSection(String courseId, SectionModel section);
  Future<void> updateSection(String courseId, SectionModel section);
  Future<void> deleteSection(String courseId, String sectionId);

  Future<void> addLesson(String courseId, String sectionId, LessonModel lesson);
  Future<void> updateLesson(String courseId, String sectionId, LessonModel lesson);
  Future<void> deleteLesson(String courseId, String sectionId, String lessonId);
}
