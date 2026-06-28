import 'package:learning_management_system/features/chat/data/models/message_model.dart';
import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';

abstract class ChatDataSource {
  Future<void> sendMessage({required String courseId, required MessageModel message});
  Future<void> readMessage({required String courseId, required String messageId});
  Stream<List<MessageEntity>> getChatMessages({required String courseId});
}