import 'package:flutter/material.dart';
import 'package:learning_management_system/core/theme/app_color.dart';

class SendMessageWidget extends StatelessWidget {
  const SendMessageWidget({required this.chatId, super.key});
  final String chatId;

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.attach_file, color: AppColors.chatSendIconColor),
        ),
        Expanded(
          child: TextFormField(
            controller: messageController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: AppColors.chatBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: AppColors.chatBorderColor),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            if (messageController.text.isNotEmpty) {}
          },
          icon: Icon(Icons.send, color: AppColors.chatSendIconColor),
        ),
      ],
    );
  }
}
