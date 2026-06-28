import 'package:learning_management_system/features/chat/data/models/course_chat_model.dart';
import 'package:learning_management_system/features/chat/data/models/message_model.dart';

abstract class ChatDataSource {
  Future<void> sendMessage({required String courseId, required MessageModel message});
  Future<void> readMessage({required String courseId, required String messageId});
  Stream<List<MessageModel>> getChatMessages({required String courseId});
  Future<List<CourseChatModel>> getCoursesChat();
}