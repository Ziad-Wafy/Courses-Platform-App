import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/chat/data/models/course_chat_model.dart';
import 'package:learning_management_system/features/chat/data/models/message_model.dart';
import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';
import 'package:learning_management_system/features/chat/domain/entities/course_chat_entity.dart';
import 'package:learning_management_system/features/chat/presentation/state_management/cubit/chat_cubit.dart';
import 'package:learning_management_system/features/chat/presentation/ui/widgets/course_bubble.dart';
import 'package:learning_management_system/features/chat/presentation/ui/widgets/message_bubble.dart';
import 'package:learning_management_system/features/chat/presentation/ui/widgets/send_message_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String selectedCourseId = "";
  List<CourseChatEntity> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    context.read<ChatCubit>().getCoursesChat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CourseChatEntity? selectedCourse = courses.firstWhere(
      (c) => c.id == selectedCourseId,
      orElse: () => CourseChatModel(
        id: '',
        title: 'Loading...',
        image: '',
        description: '',
        rating: 0,
        studentsCount: 0,
        instructor: '',
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: selectedCourse.id.isEmpty
            ? const Text(
                "Chat",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: selectedCourse.image.isNotEmpty
                          ? NetworkImage(selectedCourse.image)
                          : null,
                      child: selectedCourse.image.isEmpty
                          ? const Icon(Icons.book, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCourse.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Instructor: ${selectedCourse.instructor}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedCourse.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      body: Column(
        children: [
          BlocListener<ChatCubit, ChatState>(
            listener: (context, state) {
              if (state is ChatLoadedCourses) {
                setState(() {
                  courses = state.coursesChat;
                  isLoading = false;
                  if (courses.isNotEmpty && selectedCourseId.isEmpty) {
                    selectedCourseId = courses[0].id;
                    context.read<ChatCubit>().readMessage(
                      courseId: selectedCourseId,
                      messageId: "",
                    );
                  }
                });
              } else if (state is ChatError && isLoading) {
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }
            },
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : courses.isEmpty
                ? const Center(child: Text("no courses"))
                : Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: MediaQuery.sizeOf(context).width,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCourseId = courses[index].id;
                            });
                            context.read<ChatCubit>().readMessage(
                              courseId: courses[index].id,
                              messageId: "",
                            );
                          },
                          child: StreamBuilder<int>(
                            stream: context.read<ChatCubit>().getUnreadCount(
                              courseId: courses[index].id,
                            ),
                            builder: (context, snapshot) {
                              return CourseBubble(
                                courseName: courses[index].title,
                                unreadMessagesCount: snapshot.data ?? 0,
                                courseId: courses[index].id,
                                selectedCourseId: selectedCourseId,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),

          SizedBox(height: 8),
          Expanded(
            child: selectedCourseId.isEmpty
                ? const Center(child: Text("Select a course to start chatting"))
                : StreamBuilder<List<MessageEntity>>(
                    stream: context.read<ChatCubit>().getChatMessages(
                      courseId: selectedCourseId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return const Center(child: Text("No messages yet"));
                      }

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(message: messages[index]);
                        },
                      );
                    },
                  ),
          ),
          SizedBox(height: 8),
          SendMessageWidget(
            onSendMessage: (message) {
              context.read<ChatCubit>().sendMessage(
                courseId: selectedCourseId,
                message: MessageModel(
                  message: message,
                  sendAt: DateTime.now(),
                  senderId: FirebaseAuth.instance.currentUser!.uid,
                  senderName:
                      FirebaseAuth.instance.currentUser!.displayName ?? 'User',
                ),
              );
              context.read<ChatCubit>().readMessage(
                courseId: selectedCourseId,
                messageId: "",
              );
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

