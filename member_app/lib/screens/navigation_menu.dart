import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'member/dashboard_page.dart';
import 'member/search_page.dart'; 
import 'member/favorites_page.dart';
import 'member/chat_page.dart';
import 'member/profile_page.dart';

class MemberNavigation extends StatefulWidget {
  const MemberNavigation({super.key});

  @override
  State<MemberNavigation> createState() => _MemberNavigationState();
}

class _MemberNavigationState extends State<MemberNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const SearchPage(),    // Labeled as "መዝሙሮች"
    const FavoritesPage(),
  ];

  // Professional Woody Palette
  final Color woodDark = const Color(0xFF3E2723); // Deep Mahogany
  final Color goldAccent = const Color(0xFFFFC107); // Pure Gold
  final Color parchment = const Color(0xFFFDF5E6); // Warm Background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      backgroundColor: parchment,

      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: woodDark,
        elevation: 10,
        iconTheme: IconThemeData(color: goldAccent),
        title: Text("መዝሙርቤት", 
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          IconButton(
            onPressed: () => _showNotificationOverlay(context), 
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ],
      ),

      // 2. FULLY FUNCTIONAL WOODY DRAWER
      drawer: _buildMemberDrawer(context),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 3. RESTORED SOLID WOODY BOTTOM NAVIGATION
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // --- DRAWER IMPLEMENTATION ---
  Widget _buildMemberDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      backgroundColor: parchment,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: woodDark),
            currentAccountPicture: CircleAvatar(
              backgroundColor: goldAccent,
              child: Icon(Icons.person, color: woodDark, size: 45),
            ),
            accountName: const Text("የኳየር አባል", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            accountEmail: Text(user?.email ?? "No Email"),
          ),
          
          _drawerItem(Icons.account_circle_outlined, "የእኔ መረጃ (Profile)", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }),

          _drawerItem(Icons.chat_bubble_outline_rounded, "እርዳታ መጠየቂያ (Support)", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
          }),

          _drawerItem(Icons.info_outline_rounded, "ስለ አፕሊኬሽኑ (About App)", () {
             Navigator.pop(context);
             _showAboutAppDialog(context);
          }),

          const Spacer(),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text("ውጣ (Sign Out)", 
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => _confirmSignOut(context),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: woodDark),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  // --- NOTIFICATION OVERLAY (Recent Updates) ---
  void _showNotificationOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: parchment, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("አዳዲስ መዝሙሮች (New Updates)", 
              style: GoogleFonts.philosopher(fontSize: 18, fontWeight: FontWeight.bold, color: woodDark)),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('songs').orderBy('updatedAt', descending: true).limit(3).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();
                return Column(
                  children: snap.data!.docs.map((doc) => ListTile(
                    leading: const Icon(Icons.library_add_check, color: Colors.green),
                    title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("አዲስ መዝሙር ተጨምሯል"),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "መዝሙርቤት",
      applicationVersion: "v1.5.2",
      applicationIcon: Icon(Icons.library_music, size: 50, color: woodDark),
      children: [
        const Text("ለባህር ዳር ዩኒቨርሲቲ ክርስቲያን ተማሪዎች ህብረት (BDU-CSF) ኳየር አገልግሎት የተዘጋጀ።"),
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("መውጣት ይፈልጋሉ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("አይ")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { FirebaseAuth.instance.signOut(); Navigator.pop(ctx); }, 
            child: const Text("አዎ ውጣ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- RESTORED SOLID BOTTOM BAR ---
  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: woodDark, // FIXED: Reverted to Solid Mahogany
          selectedItemColor: goldAccent,
          unselectedItemColor: Colors.white30,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "መነሻ"),
            BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: "መዝሙሮች"), 
            BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: "የተመረጡ"),
          ],
        ),
      ),
    );
  }
}