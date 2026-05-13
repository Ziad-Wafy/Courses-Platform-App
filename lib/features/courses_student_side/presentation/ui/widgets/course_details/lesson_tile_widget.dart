import 'package:flutter/material.dart';

class LessonTileWidget extends StatelessWidget {
  final String title;
  final String duration;

  const LessonTileWidget({
    super.key,
    this.title = "Lesson Name",
    this.duration = "",
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
      title: Text(title),
      trailing: duration.isEmpty ? null : Text(duration),
    );
  }
}
