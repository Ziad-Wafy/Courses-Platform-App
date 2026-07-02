import 'package:flutter/material.dart';
import 'package:test_app/widegets/profile/logout_button.dart';
import 'package:test_app/widegets/profile/profile_header.dart';
import 'package:test_app/widegets/profile/settings_section.dart';
import 'package:test_app/widegets/profile/statistics_card.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _navIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                name: 'Alex Student',
                email: 'alex.student@university.edu',
                role: 'Student',
                onEditTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: const StatisticsCard(
                        enrolled: 8,
                        completed: 12,
                        certificates: 5,
                        avgScore: '87%',
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsSection(
                            sectionTitle: 'Account Settings',
                            items: [
                              SettingsSectionData(
                                icon: Icons.person_outline,
                                title: 'Edit Profile',
                                onTap: () {},
                              ),
                              SettingsSectionData(
                                icon: Icons.lock_outline,
                                title: 'Privacy & Security',
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SettingsSection(
                            sectionTitle: 'Support',
                            items: [
                              SettingsSectionData(
                                icon: Icons.help_outline,
                                title: 'Help Center',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LogoutButton(onTap: () {}),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5B93F5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
