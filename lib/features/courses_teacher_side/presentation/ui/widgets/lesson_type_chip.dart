import 'package:flutter/material.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/widgets/teacher_shared_widgets.dart';

class LessonTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const LessonTypeChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: TeacherShared.lightBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: TeacherShared.primaryBlue.withAlpha(102),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: TeacherShared.primaryBlue),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff4A90D9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
