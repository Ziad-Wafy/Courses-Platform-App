import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/chat/data/models/message_model.dart';
import 'package:learning_management_system/features/chat/presentation/state_manegment.dart/cubit/chat_cubit.dart';
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

  @override
  void initState() {
    context.read<ChatCubit>().getCoursesChat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChatError) {
                return Center(child: Text(state.errorMessage));
              } else if (state is ChatLoadedCourses) {
                return SizedBox(
                  height: 50,
                  width: MediaQuery.sizeOf(context).width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.coursesChat.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCourseId = state.coursesChat[index].id;
                          });
                        },
                        child: CourseBubble(
                          courseName: state.coursesChat[index].title,
                          unreadMessagesCount: 1, // TODO:: unread messages count
                          courseId: state.coursesChat[index].id,
                          selectedCourseId: selectedCourseId,
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: Text("no courses"));
              }
            },
          ),

          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: MessageModel(
                    message: "hello and how are you ?",
                    sendAt: DateTime.now(),
                    senderId: "123",
                    senderName: "Ahmed",
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          SendMessageWidget(chatId: selectedCourseId.toString()),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
