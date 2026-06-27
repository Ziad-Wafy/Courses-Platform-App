import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/models/lesson_model.dart';
import '../../screens/lesson_content_screen.dart';
import 'lesson_tile_widget.dart';

class SectionCardWidget extends StatefulWidget {
  final String courseId;
  final String sectionId;
  final String title;
  final String items;

  const SectionCardWidget({
    super.key,
    required this.courseId,
    required this.sectionId,
    required this.title,
    required this.items,
  });

  @override
  State<SectionCardWidget> createState() => _SectionCardWidgetState();
}

class _SectionCardWidgetState extends State<SectionCardWidget> {
  late Future<List<LessonModel>> lessonsFuture;

  @override
  void initState() {
    super.initState();
    lessonsFuture = getLessons();
  }

  Future<List<LessonModel>> getLessons() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('sections')
        .doc(widget.sectionId)
        .collection('lessons')
        .get();

    return snapshot.docs
        .map((doc) => LessonModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.items),
                ],
              ),
            ),

            const Divider(),

            FutureBuilder<List<LessonModel>>(
              future: lessonsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }

                final lessons = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];

                    return LessonTileWidget(
                      title: lesson.title,
                      duration: lesson.duration,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonContentScreen(
                              title: lesson.title,
                              description: lesson.description,
                              videoUrl: lesson.videoUrl,
                              pdfUrl: lesson.pdfUrl,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}