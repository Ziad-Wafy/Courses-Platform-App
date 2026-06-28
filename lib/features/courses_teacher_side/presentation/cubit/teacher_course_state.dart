import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';

abstract class TeacherCourseState {}

class TeacherCourseInitial extends TeacherCourseState {}

class TeacherCourseLoading extends TeacherCourseState {}

// ── Success states ─────────────────────────────────────────────────────────

class TeacherCourseAdded extends TeacherCourseState {
  final CourseModel course;
  TeacherCourseAdded(this.course);
}

class TeacherCourseUpdated extends TeacherCourseState {
  final CourseModel course;
  TeacherCourseUpdated(this.course);
}

class TeacherCourseDeleted extends TeacherCourseState {
  final String courseId;
  TeacherCourseDeleted(this.courseId);
}

class TeacherSectionAdded extends TeacherCourseState {
  final SectionModel section;
  TeacherSectionAdded(this.section);
}

class TeacherSectionUpdated extends TeacherCourseState {
  final SectionModel section;
  TeacherSectionUpdated(this.section);
}

class TeacherSectionDeleted extends TeacherCourseState {
  final String sectionId;
  TeacherSectionDeleted(this.sectionId);
}

class TeacherLessonAdded extends TeacherCourseState {
  final LessonModel lesson;
  TeacherLessonAdded(this.lesson);
}

class TeacherLessonUpdated extends TeacherCourseState {
  final LessonModel lesson;
  TeacherLessonUpdated(this.lesson);
}

class TeacherLessonDeleted extends TeacherCourseState {
  final String lessonId;
  TeacherLessonDeleted(this.lessonId);
}

// ── Error state ────────────────────────────────────────────────────────────

class TeacherCourseError extends TeacherCourseState {
  final String message;
  TeacherCourseError(this.message);
}
