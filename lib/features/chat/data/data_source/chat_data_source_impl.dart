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
        .collection('courses')
        .doc(courseId)
        .collection('messages')
        .doc(messageId)
        .collection('readBy')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'readAt': Timestamp.now(),
        });
  }

  @override
  Stream<List<MessageModel>> getChatMessages({required String courseId}) {
    return firestore
        .collection('courses')
        .doc(courseId)
        .collection('messages')
        .orderBy('sendAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<List<CourseChatModel>> getCoursesChat() async {
    final List<String> enrolledCoursesIDs = (await firestore
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("courses")
            .get())
        .docs
        .map((doc) => doc.id)
        .toList();

    return (await firestore
            .collection('courses')
            .where(FieldPath.documentId, whereIn: enrolledCoursesIDs)
            .get())
        .docs
        .map((doc) => CourseChatModel.fromJson(doc.data()))
        .toList();
  }
}
