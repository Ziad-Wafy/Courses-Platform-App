import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';

import '../models/course_model.dart';
import '../models/section_model.dart';

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

    print('COURSES COUNT = ${snapshot.docs.length}');

    for (var doc in snapshot.docs) {
      print(doc.id);
      print(doc.data());
    }

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

    print('==========================');
    print('SECTIONS COUNT FOR $courseId: ${snapshot.docs.length}');

    for (var doc in snapshot.docs) {
      print('SECTION ID: ${doc.id}');
      print('DATA: ${doc.data()}');
    }

    print('==========================');

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

    print(
      'LESSONS COUNT FOR $sectionId: ${snapshot.docs.length}',
    );

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
