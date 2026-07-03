import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/data/data_sources/teacher_courses_remote_data_source.dart';

class FirebaseTeacherCoursesRemoteDataSource
    implements TeacherCoursesRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseTeacherCoursesRemoteDataSource(this.firestore);

  // ── Course ────────────────────────────────────────────────────────────────

  @override
  Future<List<CourseModel>> getTeacherCourses(String teacherId) async {
    final querySnapshot = await firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    return querySnapshot.docs
        .map((doc) => CourseModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addCourse(CourseModel course) async {
    final data = course.toMap();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      data['teacherId'] = uid;
    }
    await firestore.collection('courses').doc(course.id).set(data);

    await firestore
        .collection('courses')
        .doc(course.id)
        .collection('users')
        .doc(uid)
        .set({'userId': uid});

    await firestore
        .collection('users')
        .doc(uid)
        .collection('courses')
        .doc(course.id)
        .set({'courseId': course.id});
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    await firestore.collection('courses').doc(course.id).update(course.toMap());
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await firestore.collection('courses').doc(courseId).delete();
  }

  // ── Section ───────────────────────────────────────────────────────────────

  @override
  Future<void> addSection(String courseId, SectionModel section) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(section.id)
        .set(section.toMap());
  }

  @override
  Future<void> updateSection(String courseId, SectionModel section) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(section.id)
        .update(section.toMap());
  }

  @override
  Future<void> deleteSection(String courseId, String sectionId) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .delete();
  }

  // ── Lesson ────────────────────────────────────────────────────────────────

  @override
  Future<void> addLesson(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lesson.id)
        .set(lesson.toMap());
  }

  @override
  Future<void> updateLesson(
    String courseId,
    String sectionId,
    LessonModel lesson,
  ) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lesson.id)
        .update(lesson.toMap());
  }

  @override
  Future<void> deleteLesson(
    String courseId,
    String sectionId,
    String lessonId,
  ) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }
}
