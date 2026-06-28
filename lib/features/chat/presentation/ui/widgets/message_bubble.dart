import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:learning_management_system/core/theme/app_color.dart';
import 'package:learning_management_system/features/chat/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final MessageEntity message;
  
  bool get isMe => FirebaseAuth.instance.currentUser?.uid == message.senderId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Text(
              message.senderName,
              style: TextStyle(
                color: AppColors.chatOtherMessageTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.chatMyMessageColor
                  : AppColors.chatOtherMessageColor,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: AppColors.chatBorderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: isMe
                        ? AppColors.chatMyMessageTextColor
                        : AppColors.chatOtherMessageTextColor,
                  ),
                ),
                Text(
                  "${message.sendAt.hour > 12 ? message.sendAt.hour - 12 : (message.sendAt.hour == 0 ? 12 : message.sendAt.hour)}:${message.sendAt.minute.toString().padLeft(2, '0')} ${message.sendAt.hour >= 12 ? 'PM' : 'AM'}",
                  style: TextStyle(
                    color: isMe
                        ? AppColors.chatMyMessageTextColor
                        : AppColors.chatOtherMessageTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
