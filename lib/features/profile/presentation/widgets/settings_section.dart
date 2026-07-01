import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_management_system/core/theme/app_color.dart';
import 'settings_tile.dart';

class SettingsSectionItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsSectionItem({
    required this.icon,
    required this.title,
    this.onTap,
  });
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsSectionItem> items;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.chatOtherMessageTextColor.withOpacity(0.5),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.chatMyMessageTextColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isFirst = index == 0;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  SettingsTile(
                    icon: item.icon,
                    title: item.title,
                    onTap: item.onTap,
                    isFirst: isFirst,
                    isLast: isLast,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 48.w,
                      endIndent: 0,
                      color: AppColors.secondary,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}