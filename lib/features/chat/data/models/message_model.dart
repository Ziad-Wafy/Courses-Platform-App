import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.message,
    required super.sendAt,
    required super.senderId,
    required super.senderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'sendAt': sendAt,
      'senderId': senderId,
      'senderName': senderName,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      message: map['message'],
      sendAt: map['sendAt'],
      senderId: map['senderId'],
      senderName: map['senderName'],
    );
  }
}

class ReadByModel extends ReadByEntity {
  ReadByModel({
    required super.userId,
    required super.readAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'readAt': readAt,
    };
  }

  factory ReadByModel.fromMap(Map<String, dynamic> map) {
    return ReadByModel(
      userId: map['userId'],
      readAt: map['readAt'],
    );
  }
}
