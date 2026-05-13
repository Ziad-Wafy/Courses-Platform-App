import 'package:flutter/material.dart';
import 'tab_button_widget.dart';

class CourseTabsWidget extends StatelessWidget {
  final int enrolledCount;
  final int availableCount;
  final bool isEnrolledSelected;
  final VoidCallback onEnrolledTap;
  final VoidCallback onAvailableTap;

  const CourseTabsWidget({
    super.key,
    required this.enrolledCount,
    required this.availableCount,
    required this.isEnrolledSelected,
    required this.onEnrolledTap,
    required this.onAvailableTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          TabButtonWidget(
            title: "Enrolled ($enrolledCount)",
            selected: isEnrolledSelected,
            onTap: onEnrolledTap,
          ),
          const SizedBox(width: 14),
          TabButtonWidget(
            title: "Available ($availableCount)",
            selected: !isEnrolledSelected,
            onTap: onAvailableTap,
          ),
        ],
      ),
    );
  }
}
