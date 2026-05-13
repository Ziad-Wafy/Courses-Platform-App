import 'package:flutter/material.dart';
import 'package:learning_management_system/features/chat/data/models/message_model.dart';
import 'package:learning_management_system/features/chat/presentation/ui/widgets/course_bubble.dart';
import 'package:learning_management_system/features/chat/presentation/ui/widgets/message_bubble.dart';
import 'package:learning_management_system/features/chat/presentation/ui/widgets/send_message_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int selectedCourseId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            width: MediaQuery.sizeOf(context).width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCourseId = index;
                    });
                  },
                  child: CourseBubble(
                    courseName: "course name $index",
                    unreadMessagesCount: index,
                    courseId: index,
                    selectedCourseId: selectedCourseId,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: MessageModel(
                    message: "hello and how are you ?",
                    sendAt: "12:00 PM",
                    senderId: "123",
                    senderName: "Ahmed",
                    chatId: "123",
                    isMe: index % 2 == 0,
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
