import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'lyrics_reader_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // --- PREMIUM WOODY PALETTE ---
  static const Color woodDark = Color(0xFF2B1B17);    // Deep Ebony
  static const Color mahogany = Color(0xFF3E2723);    // Rich Mahogany
  static const Color oakPrimary = Color(0xFF5D4037);  // Oak Wood
  static const Color goldAccent = Color(0xFFFFC107);  // Pure Gold
  static const Color parchment = Color(0xFFFDF5E6);   // High-Visibility Paper

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parchment, // Clean warm background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. DYNAMIC SPIRITUAL HEADER
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            backgroundColor: mahogany,
            elevation: 15,
            shadowColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "መዝሙር ቤት | Dijital Song House",
                style: GoogleFonts.philosopher(
                  color: goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle wood grain overlay
                  Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      "https://www.transparenttextures.com/patterns/wood-pattern.png",
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          woodDark.withValues(alpha: 0.8),
                          mahogany,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CHOIR BRANDING BANNER
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: mahogany,
                borderRadius: BorderRadius.circular(25), // Rounded Borders
                border: const Border(
                  bottom: BorderSide(color: goldAccent, width: 4),
                  right: BorderSide(color: goldAccent, width: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Text(
                "የባህር ዳር ዩኒቨርሲቲ የክርስቲያን ተማሪዎች ህብረት (BDU-CSF) ኳየር",
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansEthiopic(
                  color: goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),

          // 3. SECTION LABEL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: mahogany, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    "በቅርብ የተጨመሩ መዝሙሮች",
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: mahogany,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. THE DIGITAL SHELF (Staggered Animation List)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('songs')
                .orderBy('updatedAt', descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(color: mahogany),
                    ),
                  ),
                );
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text("ምንም መዝሙር አልተገኘም (Shelf Empty)"),
                  ),
                );
              }

              return AnimationLimiter(
                child: SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int i) {
                        final QueryDocumentSnapshot song = snap.data!.docs[i];
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 600),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: _buildRoundedWoodyBook(context, song),
                            ),
                          ),
                        );
                      },
                      childCount: snap.data!.docs.length,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Bottom spacing to ensure navigation bar doesn't cover content
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }

  // --- WIDGET: ROUNDED WOODY BOOK CARD ---
  Widget _buildRoundedWoodyBook(BuildContext context, DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, // Inner paper color
        borderRadius: BorderRadius.circular(20), // FULLY ROUNDED BORDER
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: oakPrimary, // Solid Wood Color
          borderRadius: BorderRadius.circular(20),
          // THE BOOK SPINE (High Contrast Gold)
          border: const Border(
            left: BorderSide(color: goldAccent, width: 12),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          title: Text(
            data['title'] ?? "ያልተሰየመ መዝሙር",
            style: GoogleFonts.notoSansEthiopic(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.music_note, size: 14, color: goldAccent),
                const SizedBox(width: 5),
                Text(
                  "${data['rhythmStyle'] ?? 'Unset'} • ${data['chordClass'] ?? 'Unset'}",
                  style: TextStyle(
                    fontSize: 12,
                    color: goldAccent.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          trailing: const CircleAvatar(
            backgroundColor: Colors.white10,
            radius: 18,
            child: Icon(Icons.chevron_right_rounded, color: goldAccent, size: 24),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LyricsReaderPage(doc: doc)),
          ),
        ),
      ),
    );
  }
}