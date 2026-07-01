import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.message,
    required super.sendAt,
    required super.isMe,
    required super.senderId,
    required super.chatId,
    required super.senderName,
  });
}
