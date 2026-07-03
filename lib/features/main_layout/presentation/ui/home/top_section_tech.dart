import 'package:flutter/material.dart';
import 'stat_card.dart';

class TopSectionTech extends StatelessWidget {
  final String teacherName;
  final int courseCount;
  final int studentCount;
  final double rating;
  final String? avatarUrl;

  const TopSectionTech({
    super.key,
    required this.teacherName,
    required this.courseCount,
    required this.studentCount,
    required this.rating,
  }) : avatarUrl = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B93F5), Color(0xFF4A7FE8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
                    teacherName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              StatCard(
                icon: Icons.menu_book_outlined,
                value: '$courseCount',
                label: 'Courses',
              ),
              const SizedBox(width: 10),
              StatCard(
                icon: Icons.people_outline,
                value: '$studentCount',
                label: 'Students',
              ),
              const SizedBox(width: 10),
              StatCard(
                icon: Icons.trending_up,
                value: rating.toStringAsFixed(1),
                label: 'Rating',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
