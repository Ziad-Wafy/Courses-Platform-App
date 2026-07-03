import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_management_system/features/chat/data/data_source/chat_data_source.dart';
import 'package:learning_management_system/features/chat/data/models/course_chat_model.dart';
import 'package:learning_management_system/features/chat/data/models/message_model.dart';

class ChatDataSourceImpl implements ChatDataSource {
  final FirebaseFirestore firestore;

  ChatDataSourceImpl(this.firestore);

  @override
  Future<void> sendMessage({
    required String courseId,
    required MessageModel message,
  }) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('messages')
        .add(message.toMap());
  }

  @override
  Future<void> readMessage({
    required String courseId,
    required String messageId,
  }) async {
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('courses')
        .doc(courseId)
        .update({'lastReadAt': Timestamp.now()})
        .catchError((_) {
          firestore
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('courses')
              .doc(courseId)
              .set({'lastReadAt': Timestamp.now()}, SetOptions(merge: true));
        });
  }

  @override
  Stream<int> getUnreadCount({required String courseId}) {
    return firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('courses')
        .doc(courseId)
        .snapshots()
        .asyncExpand((userCourseDoc) {
          final data = userCourseDoc.data();
          final lastReadAt = data != null && data.containsKey('lastReadAt')
              ? data['lastReadAt'] as Timestamp?
              : null;

          Query query = firestore
              .collection('courses')
              .doc(courseId)
              .collection('messages');

          if (lastReadAt != null) {
            query = query.where('sendAt', isGreaterThan: lastReadAt);
          }

          return query.snapshots().map((snapshot) {
            int count = 0;
            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
            for (var doc in snapshot.docs) {
              final docData = doc.data() as Map<String, dynamic>?;
              if (docData != null && docData['senderId'] != currentUserId) {
                count++;
              }
            }
            return count;
          });
        });
  }

  @override
  Stream<List<MessageModel>> getChatMessages({required String courseId}) {
    return firestore
        .collection('courses')
        .doc(courseId)
        .collection('messages')
        .orderBy('sendAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<List<CourseChatModel>> getCoursesChat() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Get user role from users collection
    final userDoc = await firestore
        .collection('users')
        .doc(currentUserId)
        .get();
    final role = userDoc.data()?['role'] as String? ?? 'Student';

    List<CourseChatModel> courses = [];

    if (role == 'Teacher') {
      // For teachers, get courses they created (using teacherId field)
      final coursesSnapshot = await firestore
          .collection('courses')
          .where('teacherId', isEqualTo: currentUserId)
          .get();

      courses = coursesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is included
        return CourseChatModel.fromJson(data);
      }).toList();

      // Fallback: also check users/courses collection if teacherId query returns nothing
      if (courses.isEmpty) {
        final List<String> enrolledCoursesIDs =
            (await firestore
                    .collection("users")
                    .doc(currentUserId)
                    .collection("courses")
                    .get())
                .docs
                .map((doc) => doc.id)
                .toList();

        if (enrolledCoursesIDs.isNotEmpty) {
          final coursesSnapshot = await firestore
              .collection('courses')
              .where(FieldPath.documentId, whereIn: enrolledCoursesIDs)
              .get();

          courses = coursesSnapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is included
            return CourseChatModel.fromJson(data);
          }).toList();
        }
      }
    } else {
      // For students, get enrolled courses
      final List<String> enrolledCoursesIDs =
          (await firestore
                  .collection("users")
                  .doc(currentUserId)
                  .collection("courses")
                  .get())
              .docs
              .map((doc) => doc.id)
              .toList();

      if (enrolledCoursesIDs.isNotEmpty) {
        final coursesSnapshot = await firestore
            .collection('courses')
            .where(FieldPath.documentId, whereIn: enrolledCoursesIDs)
            .get();

        courses = coursesSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Ensure ID is included
          return CourseChatModel.fromJson(data);
        }).toList();
      }
    }

    return courses;
  }
}
