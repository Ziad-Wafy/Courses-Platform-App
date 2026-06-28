import 'package:dartz/dartz.dart';
import 'package:learning_management_system/core/error/failure.dart';
import 'package:learning_management_system/features/chat/domain/entities/course_chat_entity.dart';
import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepo {
  Future<Either<Failure, void>> sendMessage({
    required String courseId,
    required MessageEntity message,
  });
  Future<Either<Failure, void>> readMessage({
    required String courseId,
    required String messageId,
  });
  Stream<Either<Failure, List<MessageEntity>>> getChatMessages({
    required String courseId,
  });
  Future<Either<Failure, List<CourseChatEntity>>> getCoursesChat();
  Stream<Either<Failure, int>> getUnreadCount({required String courseId});
}
