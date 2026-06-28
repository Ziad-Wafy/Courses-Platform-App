import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/chat/domain/entities/course_chat_entity.dart';
import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';
import 'package:learning_management_system/features/chat/domain/repositories/chat_repo.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;
  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  void getCoursesChat() async {
    emit(ChatLoading());
    final result = await chatRepo.getCoursesChat();
    result.fold(
      (failure) => emit(ChatError(errorMessage: failure.message)),
      (coursesChat) => emit(ChatLoadedCourses(coursesChat: coursesChat)),
    );
  }

  void sendMessage({
    required String courseId,
    required MessageEntity message,
  }) async {
    emit(ChatLoading());
    final result = await chatRepo.sendMessage(
      courseId: courseId,
      message: message,
    );
    result.fold(
      (failure) => emit(ChatError(errorMessage: failure.message)),
      (r) => emit(ChatMessageSent()),
    );
  }

  void readMessage({
    required String courseId,
    required String messageId,
  }) async {
    emit(ChatLoading());
    final result = await chatRepo.readMessage(
      courseId: courseId,
      messageId: messageId,
    );
    result.fold(
      (failure) => emit(ChatError(errorMessage: failure.message)),
      (r) => emit(ChatMessageRead()),
    );
  }

  Stream<List<MessageEntity>> getChatMessages({required String courseId}) {
    return chatRepo
        .getChatMessages(courseId: courseId)
        .map((event) => event.fold((failure) => [], (messages) => messages));
  }

  Stream<int> getUnreadCount({required String courseId}) {
    return chatRepo
        .getUnreadCount(courseId: courseId)
        .map((event) => event.fold((failure) => 0, (count) => count));
  }
}
