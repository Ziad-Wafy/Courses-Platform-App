import 'package:flutter/material.dart';

class AboutCourseWidget extends StatelessWidget {
  final String description;

  const AboutCourseWidget({
    super.key,
    this.description = "Course description here...",
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
            const Text(
              "About this course",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Text(description),
          ],
        ),
      ),
    );
  }
}
