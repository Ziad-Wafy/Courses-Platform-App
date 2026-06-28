import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_management_system/features/courses_student_side/data/data_sources/courses_remoter_data.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';

import '../models/course_model.dart';
import '../models/section_model.dart';

class FirebaseCoursesRemoteDataSource implements CoursesRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseCoursesRemoteDataSource(this.firestore);

  @override
  Future<List<CourseModel>> getCourses() async {
    print('START FETCHING COURSES');

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

    print('LESSONS COUNT FOR $sectionId: ${snapshot.docs.length}');

    return snapshot.docs
        .map((doc) => LessonModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> enrollCourse(String courseId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('users')
        .doc(userId)
        .set({'userId': userId});

    await firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .set({'courseId': courseId});
  }

  @override
  Future<List<CourseModel>> getEnrolledCourses() async {
    final snapshotCourseIds = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('courses')
        .get();

    List<String> courseIds = [];

    for (var doc in snapshotCourseIds.docs) {
      courseIds.add(doc.data()['courseId']);
    }

    if (courseIds.isEmpty) {
      return [];
    }

    final snapshot = await firestore
        .collection('courses')
        .where(FieldPath.documentId, whereIn: courseIds)
        .get();

    return snapshot.docs
        .map((doc) => CourseModel.fromJson(doc.data(), doc.id))
        .toList();
  }
}
