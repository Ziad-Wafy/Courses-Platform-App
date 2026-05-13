import 'package:flutter/material.dart';
import 'lesson_tile_widget.dart';

class SectionCardWidget extends StatelessWidget {
  final String title;
  final String items;

  const SectionCardWidget({
    super.key,
    this.title = "Section Name",
    this.items = "0 items",
  });

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
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(items),
                ],
              ),
            ),
            const Divider(),
            const LessonTileWidget(),
          ],
        ),
      ),
    );
  }
}
