part of 'chat_cubit.dart';

sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatError extends ChatState {
  final String errorMessage;
  ChatError({required this.errorMessage});
}

final class ChatLoadedCourses extends ChatState {
  final List<CourseChatEntity> coursesChat;
  ChatLoadedCourses({required this.coursesChat});
}

final class ChatMessageSent extends ChatState {}

final class ChatMessageRead extends ChatState {}
