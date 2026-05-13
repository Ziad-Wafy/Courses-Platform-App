import 'package:flutter/material.dart';

class CourseCardWidget extends StatelessWidget {
  final String title;
  final String instructor;
  final String students;
  final String rating;
  final VoidCallback onTap;

  const CourseCardWidget({
    super.key,
    required this.title,
    required this.instructor,
    required this.students,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(instructor),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(students),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(rating),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
