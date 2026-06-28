import 'package:flutter/material.dart';
import 'package:learning_management_system/core/theme/app_color.dart';

class CourseBubble extends StatefulWidget {
  final String courseName;
  final int unreadMessagesCount;
  final String courseId;
  final String selectedCourseId;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: widget.courseId == widget.selectedCourseId
              ? AppColors.chatSelectedCourseColor
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (widget.courseId != widget.selectedCourseId)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color: widget.courseId == widget.selectedCourseId
                ? AppColors.chatSelectedCourseColor
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_rounded,
              size: 20,
              color: widget.courseId == widget.selectedCourseId
                  ? Colors.white
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              widget.courseName,
              style: TextStyle(
                color: widget.courseId == widget.selectedCourseId
                    ? Colors.white
                    : Colors.black87,
                fontSize: 14,
                fontWeight: widget.courseId == widget.selectedCourseId
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
            if (widget.unreadMessagesCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${widget.unreadMessagesCount > 99 ? '99+' : widget.unreadMessagesCount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
