import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';

abstract class CoursesRemoteDataSource {
  Future<List<CourseModel>> getCourses();

  Future<List<LessonModel>> getLessons(
    String courseId,
    String sectionId,
  );

  Future<List<SectionModel>> getSections(String courseId);
}

class FirebaseCoursesRemoteDataSource implements CoursesRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseCoursesRemoteDataSource(this.firestore);

  @override
  Future<List<CourseModel>> getCourses() async {
    final snapshot = await firestore.collection('courses').get();

    return snapshot.docs
        .map((doc) => CourseModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<SectionModel>> getSections(String courseId) async {
    final snapshot = await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .get();

    return snapshot.docs
        .map((doc) => SectionModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<LessonModel>> getLessons(
    String courseId,
    String sectionId,
  ) async {
    final snapshot = await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .get();

    return snapshot.docs
        .map(
          (doc) => LessonModel.fromJson(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }
}
