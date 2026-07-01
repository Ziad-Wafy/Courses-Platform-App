import 'package:flutter/material.dart';
import 'package:learning_management_system/core/theme/app_color.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({required this.chatId, super.key});
  final String chatId;

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.attach_file, color: AppColors.chatSendIconColor),
        ),
        Expanded(
          child: TextFormField(
            controller: messageController,
            decoration: const InputDecoration(
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
            if (messageController.text.isNotEmpty) {
              // TODO: Send message logic
              messageController.clear();
            }
          },
          icon: const Icon(Icons.send, color: AppColors.chatSendIconColor),
        ),
      ],
    );
  }
}
