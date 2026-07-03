import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color valueColor;
  final Color labelColor;
  final Color? iconBackgroundColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor = Colors.white,
    this.labelColor = Colors.white70,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: iconBackgroundColor ?? Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: valueColor, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}