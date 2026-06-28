import 'package:dartz/dartz.dart';
import 'package:learning_management_system/core/error/failure.dart';
import 'package:learning_management_system/features/chat/data/data_source/chat_data_source.dart';
import 'package:learning_management_system/features/chat/domain/entities/course_chat_entity.dart';
import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';
import 'package:learning_management_system/features/chat/domain/repositories/chat_repo.dart';

class ChatRepoImpl implements ChatRepo {
  final ChatDataSource chatDataSource;

  ChatRepoImpl({required this.chatDataSource});

  @override
  Future<Either<Failure, void>> readMessage({
    required String courseId,
    required String messageId,
  }) async {
    try {
      await chatDataSource.readMessage(
        courseId: courseId,
        messageId: messageId,
      );
      return Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String courseId,
    required MessageEntity message,
  }) async {
    try {
      await chatDataSource.sendMessage(
        courseId: courseId,
        message: message.toModel(),
      );
      return Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getChatMessages({
    required String courseId,
  }) {
    try {
      return chatDataSource.getChatMessages(courseId: courseId).map((messages) {
        return Right(messages);
      });
    } catch (e) {
      return Stream.value(Left(Failure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<CourseChatEntity>>> getCoursesChat() async {
    try {
      return Right(await chatDataSource.getCoursesChat());
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
