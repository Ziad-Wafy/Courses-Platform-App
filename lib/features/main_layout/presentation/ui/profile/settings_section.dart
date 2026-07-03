import 'package:flutter/material.dart';
import 'settings_list_item.dart';

class SettingsSectionData {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsSectionData({
    required this.icon,
    required this.title,
    this.onTap,
  });
}

class SettingsSection extends StatelessWidget {
  final String sectionTitle;
  final List<SettingsSectionData> items;

  const SettingsSection({
    super.key,
    required this.sectionTitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...items.map(
          (item) => SettingsListItem(
            icon: item.icon,
            title: item.title,
            onTap: item.onTap,
          ),
        ),
      ],
    );
  }
}