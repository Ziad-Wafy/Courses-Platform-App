import 'package:flutter/material.dart';

class LessonTileWidget extends StatelessWidget {
  final String title;
  final String duration;
  final VoidCallback? onTap;

  const LessonTileWidget({
    super.key,
    required this.title,
    required this.duration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const CircleAvatar(
        child: Icon(Icons.play_arrow),
      ),
      title: Text(title),
      trailing: duration.isEmpty
          ? null
          : Text(duration),
    );
  }
}