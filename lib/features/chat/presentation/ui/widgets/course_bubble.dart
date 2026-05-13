import 'package:flutter/material.dart';
import 'package:learning_management_system/core/theme/app_color.dart';

class CourseBubble extends StatefulWidget {
  final String courseName;
  final int unreadMessagesCount;
  final int courseId;
  final int selectedCourseId;
  const CourseBubble({
    super.key,
    required this.courseName,
    required this.unreadMessagesCount,
    required this.courseId,
    required this.selectedCourseId,
  });
  @override
  State<CourseBubble> createState() => _CourseBubbleState();
}

class _CourseBubbleState extends State<CourseBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: widget.courseId == widget.selectedCourseId
              ? AppColors.chatSelectedCourseColor
              : AppColors.chatUnselectedCourseColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: AppColors.chatBorderColor, width: 1),
        ),
        child: Row(
          spacing: 4,
          children: [
            Icon(Icons.menu_book, size: 24, color: AppColors.chatBorderColor),
            Text(
              widget.courseName,
              style: TextStyle(
                color: AppColors.chatOtherMessageTextColor,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.chatUnreadMessageCountColor,
                borderRadius: BorderRadius.all(Radius.circular(360)),
              ),
              child: Text(
                "${widget.unreadMessagesCount}",
                style: TextStyle(
                  color: AppColors.chatUnreadMessageCountTextColor,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
