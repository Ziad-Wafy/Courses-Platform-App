import 'package:flutter/material.dart';

/// Shared constants and widgets for teacher screens
class TeacherShared {
  // ── Colors ────────────────────────────────────────────────────────────────

  static const Color primaryBlue = Color(0xff4A90D9);
  static const Color backgroundColor = Color(0xffF4F5F7);
  static const Color lightBlue = Color(0xffEDF4FD);
  static const Color errorColor = Colors.redAccent;
  static const Color successColor = Colors.green;

  // ── Border Radius ───────────────────────────────────────────────────────────

  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 18.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 25.0;

  // ── Button Heights ───────────────────────────────────────────────────────────

  static const double buttonHeightSmall = 44.0;
  static const double buttonHeightMedium = 52.0;

  // ── Spacing ─────────────────────────────────────────────────────────────────

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;
}

/// Shared input decoration for form fields
InputDecoration teacherInputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: TeacherShared.backgroundColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(TeacherShared.radiusMedium),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(TeacherShared.radiusMedium),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(TeacherShared.radiusMedium),
      borderSide: const BorderSide(
        color: TeacherShared.primaryBlue,
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(TeacherShared.radiusMedium),
      borderSide: const BorderSide(color: TeacherShared.errorColor),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  );
}

/// Primary button style
ButtonStyle teacherPrimaryButtonStyle({bool isDisabled = false}) {
  return ElevatedButton.styleFrom(
    backgroundColor: TeacherShared.primaryBlue,
    disabledBackgroundColor: TeacherShared.primaryBlue.withAlpha(128),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TeacherShared.radiusMedium),
    ),
  );
}

/// Outlined button style
ButtonStyle teacherOutlinedButtonStyle() {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TeacherShared.radiusMedium),
    ),
  );
}

/// Standard header container with back button
Widget teacherHeader({
  required BuildContext context,
  required String title,
  VoidCallback? onBackPressed,
  List<Widget>? actions,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(8, 12, 16, 18),
    decoration: const BoxDecoration(
      color: TeacherShared.primaryBlue,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(TeacherShared.radiusXXL),
        bottomRight: Radius.circular(TeacherShared.radiusXXL),
      ),
    ),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: onBackPressed ?? () => Navigator.pop(context),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actions != null) ...actions,
      ],
    ),
  );
}

/// Standard card container
Widget teacherCard({required Widget child, EdgeInsetsGeometry? padding}) {
  return Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(TeacherShared.radiusXL),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}

/// Standard dialog for adding/editing sections
Future<SectionDialogResult?> showSectionDialog({
  required BuildContext context,
  String? initialTitle,
  String? initialDuration,
  String title = 'Add Section',
  String actionText = 'Add',
}) {
  final titleCtrl = TextEditingController(text: initialTitle);
  final durationCtrl = TextEditingController(text: initialDuration);

  return showDialog<SectionDialogResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TeacherShared.radiusMedium),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            autofocus: true,
            decoration: teacherInputDecoration(
              'Section Title',
              hint: 'e.g., Introduction',
            ),
          ),
          const SizedBox(height: TeacherShared.spacingM),
          TextField(
            controller: durationCtrl,
            decoration: teacherInputDecoration(
              'Duration',
              hint: 'e.g., 2 Hours',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleCtrl.text.trim().isEmpty) return;
            Navigator.pop(
              ctx,
              SectionDialogResult(
                title: titleCtrl.text.trim(),
                duration: durationCtrl.text.trim(),
              ),
            );
          },
          style: teacherPrimaryButtonStyle(),
          child: Text(actionText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class SectionDialogResult {
  final String title;
  final String duration;
  SectionDialogResult({required this.title, required this.duration});
}

/// Standard loading indicator
Widget teacherLoadingIndicator() {
  return const Center(
    child: CircularProgressIndicator(color: TeacherShared.primaryBlue),
  );
}

/// Standard error message
Widget teacherErrorMessage({required String message, VoidCallback? onRetry}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline,
          color: TeacherShared.errorColor,
          size: 48,
        ),
        const SizedBox(height: TeacherShared.spacingM),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: TeacherShared.errorColor),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: TeacherShared.spacingL),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ],
    ),
  );
}

/// Standard empty state
Widget teacherEmptyState({required IconData icon, required String message}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: TeacherShared.spacingM),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      ],
    ),
  );
}
