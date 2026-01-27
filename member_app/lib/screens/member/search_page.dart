import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'lyrics_reader_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = "";
  String _selectedStyle = "All"; // Navigator state

  // --- PREMIUM WOODY PALETTE ---
  static const Color woodDark = Color(0xFF2B1B17);    // Deep Ebony
  static const Color mahogany = Color(0xFF3E2723);    // Rich Mahogany
  static const Color oakPrimary = Color(0xFF5D4037);  // Oak Wood
  static const Color goldAccent = Color(0xFFFFC107);  // Pure Gold
  static const Color parchment = Color(0xFFFDF5E6);   // High-Visibility Paper

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: mahogany,
        elevation: 10,
        title: _buildSearchTextField(),
        iconTheme: const IconThemeData(color: goldAccent),
      ),
      body: Column(
        children: [
          // 1. DYNAMIC STYLE NAVIGATOR (The Clustered Row)
          _buildStyleNavigator(),

          // 2. SEARCH RESULTS (The Woody Shelf)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('songs')
                  .orderBy('title')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: mahogany));
                }

                // Filter logic: Search input + Style Cluster
                final List<QueryDocumentSnapshot> filteredList = snap.data!.docs.where((doc) {
                  final String title = doc['title'].toString().toLowerCase();
                  final String lyrics = doc['lyrics'].toString().toLowerCase();
                  final String style = doc['rhythmStyle'] ?? "Other";

                  bool matchesSearch = title.contains(_searchQuery) || lyrics.contains(_searchQuery);
                  bool matchesCluster = (_selectedStyle == "All") || (style == _selectedStyle);

                  return matchesSearch && matchesCluster;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: mahogany.withValues(alpha: 0.2)),
                        const SizedBox(height: 10),
                        const Text("ምንም አልተገኘም (No results found)", 
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 120),
                    itemCount: filteredList.length,
                    itemBuilder: (BuildContext context, int i) {
                      final QueryDocumentSnapshot song = filteredList[i];
                      return AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 30.0,
                          child: FadeInAnimation(
                            child: _buildRoundedWoodyCard(context, song),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: APPBAR SEARCH FIELD ---
  Widget _buildSearchTextField() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        cursorColor: goldAccent,
        decoration: InputDecoration(
          hintText: "መዝሙር ፈልግ (Search title or lyrics)...",
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: goldAccent, size: 20),
          contentPadding: const EdgeInsets.only(top: 10),
        ),
        onChanged: (String v) => setState(() => _searchQuery = v.toLowerCase()),
      ),
    );
  }

  // --- WIDGET: THE STYLE NAVIGATOR (CLUSTERED BUTTONS) ---
  Widget _buildStyleNavigator() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('app_config').doc('rhythms').snapshots(),
      builder: (context, snap) {
        List<String> styles = ["All"];
        if (snap.hasData && snap.data!.exists) {
          styles.addAll(List<String>.from(snap.data!['list'] ?? []));
        }

        return Container(
          height: 65,
          color: mahogany,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: styles.length,
            itemBuilder: (context, i) {
              final bool isSelected = _selectedStyle == styles[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(styles[i]),
                  selected: isSelected,
                  onSelected: (bool selected) => setState(() => _selectedStyle = styles[i]),
                  selectedColor: goldAccent,
                  backgroundColor: woodDark,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: isSelected ? 4 : 0,
                  pressElevation: 8,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --- WIDGET: ROUNDED WOODY CARD (Consistent with Dashboard) ---
  Widget _buildRoundedWoodyCard(BuildContext context, DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          color: oakPrimary, // High-contrast woody color
          borderRadius: BorderRadius.circular(20),
          // THE GOLDEN SPINE
          border: const Border(
            left: BorderSide(color: goldAccent, width: 10),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          title: Text(
            data['title'] ?? "ያልተሰየመ መዝሙር",
            style: GoogleFonts.notoSansEthiopic(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              data['rhythmStyle'] ?? "Standard",
              style: TextStyle(
                fontSize: 12,
                color: goldAccent.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: goldAccent),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LyricsReaderPage(doc: doc)),
          ),
        ),
      ),
    );
  }
}