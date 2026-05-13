import 'package:flutter/material.dart';

class CourseHeaderWidget extends StatelessWidget {
  final String title;
  final String instructor;

  const CourseHeaderWidget({
    super.key,
    this.title = "Course Name",
    this.instructor = "Instructor Name",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xff5EA2FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.arrow_back_ios_new, color: Colors.white),
              SizedBox(width: 6),
              Text("Back", style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      instructor,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
