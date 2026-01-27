import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// Navigation Imports
import 'song_manager_page.dart';
import 'member_manager_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // HIGH-CONTRAST WOODY PALETTE
  final Color woodDark = const Color(0xFF2B1B17); 
  final Color mahogany = const Color(0xFF3E2723); 
  final Color oak = const Color(0xFF5D4037);     
  final Color gold = const Color(0xFFFFC107);    
  final Color parchment = const Color(0xFFFDF5E6); 

  // HIGH-CONTRAST CHART COLORS (VIVID)
  final List<Color> chartColors = const [
    Color(0xFFFFC107), // Gold
    Color(0xFF2196F3), // Vivid Blue
    Color(0xFF4CAF50), // Emerald Green
    Color(0xFFF44336), // Crimson Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parchment,
      // 1. CLEAN APPBAR WITH ACCOUNT ICON
      appBar: AppBar(
        backgroundColor: mahogany,
        elevation: 10,
        centerTitle: false,
        title: Text(
          "የመዝሙርቤት |Admin DASHBOARD",
          style: GoogleFonts.philosopher(
            color: gold, 
            fontWeight: FontWeight.bold, 
            fontSize: 20
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: gold, size: 32),
            onPressed: () => _showAccountSheet(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "አጠቃላይ መረጃ (STATS)", 
              style: GoogleFonts.notoSansEthiopic(
                  color: mahogany, 
                  fontWeight: FontWeight.w800, 
                  fontSize: 16),
            ),
            const SizedBox(height: 20),

            // 2. NAVIGATION METRIC CARDS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('songs').snapshots(),
              builder: (context, songSnap) => StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, userSnap) {
                  int sCount = songSnap.hasData ? songSnap.data!.docs.length : 0;
                  int uCount = userSnap.hasData ? userSnap.data!.docs.length : 0;

                  return Row(
                    children: [
                      _navActionCard(context, "መዝሙሮች", sCount.toString(), Icons.library_music, const SongManagerPage()),
                      const SizedBox(width: 15),
                      _navActionCard(context, "አባላት", uCount.toString(), Icons.people, const MemberManagerPage()),
                    ],
                  );
                }
              ),
            ),

            const SizedBox(height: 40),
            Text(
              "የመዝሙሮች ስርጭት (ANALYSIS)", 
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  color: mahogany),
            ),
            const SizedBox(height: 20),

            // 3. VIVID CHART ANALYSIS SECTION
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('songs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.brown));

                Map<String, double> rhythmMap = {};
                Map<String, double> chordMap = {};

                for (var doc in snapshot.data!.docs) {
                  String r = doc['rhythmStyle'] ?? 'Unset';
                  String c = doc['chordClass'] ?? 'Unset';
                  rhythmMap[r] = (rhythmMap[r] ?? 0) + 1;
                  chordMap[c] = (chordMap[c] ?? 0) + 1;
                }

                return Column(
                  children: [
                    _chartBox("በመዝሙር ስልት (By Rhythm)", rhythmMap),
                    const SizedBox(height: 20),
                    _chartBox("በክፍል (By Class/chordMap)", chordMap),
                  ],
                );
              },
            ),
            const SizedBox(height: 120), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _navActionCard(BuildContext context, String title, String val, IconData icon, Widget target) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: mahogany,
            borderRadius: BorderRadius.circular(25),
            // Updated withValues to fix deprecation
            border: Border.all(color: gold.withValues(alpha: 0.2), width: 1), 
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: gold, size: 28),
              const SizedBox(height: 12),
              Text(val, style: GoogleFonts.poppins(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartBox(String title, Map<String, double> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: mahogany.withValues(alpha: 0.1), width: 1), 
        boxShadow: [BoxShadow(color: woodDark.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF3E2723))),
          const SizedBox(height: 25),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: data.entries.map((e) {
                        int index = data.keys.toList().indexOf(e.key);
                        // Using high-contrast solid colors
                        return PieChartSectionData(
                          color: chartColors[index % chartColors.length],
                          value: e.value,
                          radius: 18,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.entries.map((e) {
                        int index = data.keys.toList().indexOf(e.key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10, 
                                height: 10, 
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, 
                                  color: chartColors[index % chartColors.length]
                                )
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text("${e.key}: ${e.value.toInt()}", 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: parchment, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: gold.withValues(alpha: 0.5), width: 1.5)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: oak.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 35),
              CircleAvatar(
                radius: 45, 
                backgroundColor: mahogany, 
                child: const CircleAvatar(radius: 41, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF3E2723), size: 45))
              ),
              const SizedBox(height: 20),
              const Text("የኳየር አስተዳዳሪ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              Text(FirebaseAuth.instance.currentUser?.email ?? "Email Not Found", style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.power_settings_new_rounded, color: Colors.red),
                title: const Text("ውጣ (Sign Out)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}