import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';
import 'stat_item.dart';

class StatsCard extends StatelessWidget {
  final List<StatItem> stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // نقسم الـ stats لـ rows من 2
    final rows = <List<StatItem>>[];
    for (var i = 0; i < stats.length; i += 2) {
      rows.add(stats.sublist(i, i + 2 > stats.length ? stats.length : i + 2));
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.chatMyMessageTextColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ يمنع الـ expand الزيادة
        children: [
          Text(
            "Statistics",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.chatOtherMessageTextColor,
            ),
          ),
          SizedBox(height: 20.h),
          // ✅ Row يدوي بدل GridView — يحل الـ overflow تماماً
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: entry.value,
                ),
                if (!isLast) SizedBox(height: 20.h),
              ],
            );
          }),
        ],
      ),
    );
  }
}