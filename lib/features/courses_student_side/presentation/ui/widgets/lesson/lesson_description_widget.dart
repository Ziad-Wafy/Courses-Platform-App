import 'package:flutter/material.dart';

class LessonDescriptionWidget extends StatelessWidget {
  final String title;
  final String description;

  const LessonDescriptionWidget({
    super.key,
    this.title = "Lesson Title",
    this.description = "Lesson description from Firebase later.",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Text(description),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.description, color: Colors.grey),
                SizedBox(width: 10),
                Text("Notes available"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
