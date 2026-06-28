import 'package:flutter/material.dart';
import 'package:learning_management_system/core/theme/app_color.dart';

class SendMessageWidget extends StatelessWidget {
  final Function(String message) onSendMessage;
  const SendMessageWidget({required this.onSendMessage, super.key});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.attach_file, color: Colors.grey.shade500),
              splashRadius: 24,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextFormField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xffF4F5F7),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.chatSelectedCourseColor, // Use theme primary
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.chatSelectedCourseColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  if (messageController.text.trim().isNotEmpty) {
                    onSendMessage(messageController.text.trim());
                    messageController.clear();
                  }
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
