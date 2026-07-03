import 'package:learning_management_system/features/chat/data/models/message_model.dart';

abstract class MessageEntity {
  final String message;
  final DateTime sendAt;
  final String senderId;
  final String senderName;
  MessageEntity({
    required this.message,
    required this.sendAt,
    required this.senderId,
    required this.senderName,
  });
  MessageModel toModel() {
    return MessageModel(
      message: message,
      sendAt: sendAt,
      senderId: senderId,
      senderName: senderName,
    );
  }
}

abstract class ReadByEntity {
  final String userId;
  final DateTime readAt;
  ReadByEntity({
    required this.userId,
    required this.readAt,
  });
}
