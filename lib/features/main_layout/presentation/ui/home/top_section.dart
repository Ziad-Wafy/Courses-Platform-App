import 'package:flutter/material.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/stat_card.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';

class TopSection extends StatelessWidget {
  final String userName;
  final UserStats stats;

  const TopSection({super.key, required this.userName, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF5596F6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('👋', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatCard(
                icon: Icons.menu_book,
                value: '${stats.courses}',
                label: 'Courses',
              ),
              StatCard(
                icon: Icons.emoji_events_outlined,
                value: '${stats.completed}',
                label: 'Completed',
              ),
              StatCard(
                icon: Icons.trending_up,
                value: '${(stats.progress * 100).toInt()}%',
                label: 'Progress',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
