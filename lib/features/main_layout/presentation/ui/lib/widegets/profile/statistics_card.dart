import 'package:flutter/material.dart';
import 'profile_stat_item.dart';

class StatisticsCard extends StatelessWidget {
  final int enrolled;
  final int completed;
  final int certificates;
  final String avgScore;

  const StatisticsCard({
    super.key,
    required this.enrolled,
    required this.completed,
    required this.certificates,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ProfileStatItem(
                  iconWidget: const Icon(Icons.menu_book_outlined,
                      color: Color(0xFF5B93F5)),
                  value: '$enrolled',
                  label: 'Enrolled',
                ),
              ),
              Expanded(
                child: ProfileStatItem(
                  iconWidget: const Icon(Icons.workspace_premium_outlined,
                      color: Color(0xFF5B93F5)),
                  value: '$completed',
                  label: 'Completed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ProfileStatItem(
                  iconWidget: const Icon(Icons.military_tech_outlined,
                      color: Color(0xFF5B93F5)),
                  value: '$certificates',
                  label: 'Certificates',
                ),
              ),
              Expanded(
                child: ProfileStatItem(
                  iconWidget:
                      const Icon(Icons.bar_chart, color: Color(0xFF5B93F5)),
                  value: avgScore,
                  label: 'Avg Score',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
