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
  Stream<List<CourseChatModel>> getCoursesChat() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .asyncExpand((userDoc) {
          final role = userDoc.data()?['role'] as String? ?? 'Student';

          if (role == 'Teacher') {
            return firestore
                .collection('courses')
                .where('teacherId', isEqualTo: currentUserId)
                .snapshots()
                .map((snapshot) {
                  return snapshot.docs.map((doc) {
                    final data = doc.data();
                    data['id'] = doc.id;
                    return CourseChatModel.fromJson(data);
                  }).toList();
                });
          } else {
            return firestore
                .collection("users")
                .doc(currentUserId)
                .collection("courses")
                .snapshots()
                .asyncMap((snapshot) async {
                  final List<CourseChatModel> courses = [];
                  for (var doc in snapshot.docs) {
                    final courseDoc = await firestore
                        .collection('courses')
                        .doc(doc.id)
                        .get();
                    if (courseDoc.exists) {
                      final data = courseDoc.data() ?? {};
                      data['id'] = courseDoc.id;
                      courses.add(CourseChatModel.fromJson(data));
                    }
                  }
                  return courses;
                });
          }
        });
  }
}
