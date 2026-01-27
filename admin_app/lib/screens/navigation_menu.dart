import 'dart:ui';
import 'package:flutter/material.dart';
import 'admin/dashboard_page.dart';
import 'admin/song_manager_page.dart';
import 'admin/member_manager_page.dart';
import 'admin/chat_list_page.dart';
import 'admin/management_hub.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  // FIXED: Changed signature to avoid "Private type in public API" warning
  State<AdminMainNavigation> createState() => AdminMainNavigationState();
}

// FIXED: Made class public (removed underscore) to satisfy public API lint
class AdminMainNavigationState extends State<AdminMainNavigation> {
  int _currentIndex = 0;

  // Explicitly typed list for performance and strict inference
  final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    const SongManagerPage(),
    const MemberManagerPage(),
    const ChatListPage(),
    const ManagementHub(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Content scrolls behind the bar for high-end look
      body: IndexedStack(
        index: _currentIndex, 
        children: _pages,
      ),
      bottomNavigationBar: _buildGlassDock(),
    );
  }

  Widget _buildGlassDock() {
    // High-Contrast Woody Palette
    const Color mahogany = Color(0xFF3E2723);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              // FIXED: Replaced withOpacity with withValues to fix deprecation warning
              color: mahogany.withValues(alpha: 0.9),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _navItem(0, Icons.analytics_rounded, "Stats"),
                _navItem(1, Icons.menu_book_rounded, "Shelf"),
                _navItem(2, Icons.people_rounded, "Members"),
                _navItem(3, Icons.forum_rounded, "Chat"),
                _navItem(4, Icons.settings_suggest_rounded, "System"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool active = _currentIndex == index;
    const Color goldAccent = Color(0xFFFFC107);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon, 
            color: active ? goldAccent : Colors.white38, 
            size: active ? 28 : 22,
          ),
          if (active) 
            Text(
              label, 
              style: const TextStyle(
                color: goldAccent, 
                fontSize: 10, 
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}