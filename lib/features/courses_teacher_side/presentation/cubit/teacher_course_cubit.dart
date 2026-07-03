import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/add_course_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/add_lesson_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/add_section_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/delete_course_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/delete_lesson_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/delete_section_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/update_course_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/update_lesson_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/update_section_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_state.dart';

class TeacherCourseCubit extends Cubit<TeacherCourseState> {
  final AddCourseUseCase addCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  final AddSectionUseCase addSectionUseCase;
  final UpdateSectionUseCase updateSectionUseCase;
  final DeleteSectionUseCase deleteSectionUseCase;

  final AddLessonUseCase addLessonUseCase;
  final UpdateLessonUseCase updateLessonUseCase;
  final DeleteLessonUseCase deleteLessonUseCase;

  TeacherCourseCubit({
    required this.addCourseUseCase,
    required this.updateCourseUseCase,
    required this.deleteCourseUseCase,
    required this.addSectionUseCase,
    required this.updateSectionUseCase,
    required this.deleteSectionUseCase,
    required this.addLessonUseCase,
    required this.updateLessonUseCase,
    required this.deleteLessonUseCase,
  }) : super(TeacherCourseInitial());

  // ── Course ────────────────────────────────────────────────────────────────

  Future<void> addCourse(CourseModel course) async {
    emit(TeacherCourseLoading());
    try {
      await addCourseUseCase(course);
      emit(TeacherCourseAdded(course));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    emit(TeacherCourseLoading());
    try {
      await updateCourseUseCase(course);
      emit(TeacherCourseUpdated(course));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  Future<void> deleteCourse(String courseId) async {
    emit(TeacherCourseLoading());
    try {
      await deleteCourseUseCase(courseId);
      emit(TeacherCourseDeleted(courseId));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  // ── Section ───────────────────────────────────────────────────────────────

  Future<void> addSection(String courseId, SectionModel section) async {
    emit(TeacherCourseLoading());
    try {
      await addSectionUseCase(courseId, section);
      emit(TeacherSectionAdded(section));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  Future<void> updateSection(String courseId, SectionModel section) async {
    emit(TeacherCourseLoading());
    try {
      await updateSectionUseCase(courseId, section);
      emit(TeacherSectionUpdated(section));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  Future<void> deleteSection(String courseId, String sectionId) async {
    emit(TeacherCourseLoading());
    try {
      await deleteSectionUseCase(courseId, sectionId);
      emit(TeacherSectionDeleted(sectionId));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  // ── Lesson ────────────────────────────────────────────────────────────────

  Future<void> addLesson(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    emit(TeacherCourseLoading());
    try {
      await addLessonUseCase(courseId, sectionId, lesson);
      emit(TeacherLessonAdded(lesson));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  Future<void> updateLesson(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    emit(TeacherCourseLoading());
    try {
      await updateLessonUseCase(courseId, sectionId, lesson);
      emit(TeacherLessonUpdated(lesson));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }

  Future<void> deleteLesson(
    String courseId,
    String sectionId,
    String lessonId,
  ) async {
    emit(TeacherCourseLoading());
    try {
      await deleteLessonUseCase(courseId, sectionId, lessonId);
      emit(TeacherLessonDeleted(lessonId));
    } catch (e) {
      emit(TeacherCourseError(e.toString()));
    }
  }
}
