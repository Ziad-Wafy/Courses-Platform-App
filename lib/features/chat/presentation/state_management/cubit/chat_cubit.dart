import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/chat/domain/entities/course_chat_entity.dart';
import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';
import 'package:learning_management_system/features/chat/domain/repositories/chat_repo.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;
  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  StreamSubscription? _coursesChatSubscription;

  void getCoursesChat() {
    emit(ChatLoading());
    _coursesChatSubscription?.cancel();
    _coursesChatSubscription = chatRepo.getCoursesChat().listen((result) {
      result.fold(
        (failure) => emit(ChatError(errorMessage: failure.message)),
        (coursesChat) => emit(ChatLoadedCourses(coursesChat: coursesChat)),
      );
    });
  }

  @override
  Future<void> close() {
    _coursesChatSubscription?.cancel();
    return super.close();
  }

  void sendMessage({
    required String courseId,
    required MessageEntity message,
  }) async {
    // Don't emit ChatLoading here — it causes a full screen rebuild
    final result = await chatRepo.sendMessage(
      courseId: courseId,
      message: message,
    );
    result.fold(
      (failure) => emit(ChatError(errorMessage: failure.message)),
      (r) => null, // Messages update via StreamBuilder, no state emit needed
    );
  }

  void readMessage({
    required String courseId,
    required String messageId,
  }) async {
    // Fire-and-forget: no need to emit loading state for read receipts
    await chatRepo.readMessage(
      courseId: courseId,
      messageId: messageId,
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
