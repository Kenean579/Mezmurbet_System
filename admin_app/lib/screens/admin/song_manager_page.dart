import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'song_editor_page.dart';

class SongManagerPage extends StatefulWidget {
  const SongManagerPage({super.key});

  @override
  State<SongManagerPage> createState() => _SongManagerPageState();
}

class _SongManagerPageState extends State<SongManagerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> localDrafts = <Map<String, dynamic>>[];
  
  // Search and Filter State
  String _searchQuery = "";
  String _selectedFilter = "All";

  // HIGH-CONTRAST WOODY PALETTE
  final Color woodDark = const Color(0xFF2B1B17); 
  final Color mahogany = const Color(0xFF3E2723); 
  final Color goldAccent = const Color(0xFFFFC107); 
  final Color shelfOak = const Color(0xFF5D4037); 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawDrafts = prefs.getStringList('local_drafts') ?? <String>[];
    setState(() {
      localDrafts = rawDrafts.map((String e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: woodDark,
      appBar: AppBar(
        backgroundColor: mahogany,
        elevation: 15,
        title: Text(
          "መዝሙር ቤት |SONG'S SHELF",
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: goldAccent,
          indicatorWeight: 4, 
          labelColor: goldAccent, 
          unselectedLabelColor: Colors.white, 
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          tabs: const <Widget>[
            Tab(
              text: "ያለቁ መዝሙሮች(Saved)", 
              icon: Icon(Icons.cloud_done_rounded, size: 24),
            ),
            Tab(
              text: "ረቂቆች (WORKROOM)", 
              icon: Icon(Icons.history_edu_rounded, size: 24),
            ),
          ],
        ),
      ),
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 95),
        child: FloatingActionButton.extended(
          heroTag: "song_manager_fab",
          backgroundColor: goldAccent,
          onPressed: () async {
            final bool? refresh = await Navigator.push(
              context, MaterialPageRoute<bool>(builder: (BuildContext context) => const SongEditorPage())
            );
            if (refresh == true) {
              _loadDrafts();
            }
          },
          label: Text("መዝሙር ጨምር (ADD)", 
            style: GoogleFonts.notoSansEthiopic(color: Colors.black, fontWeight: FontWeight.w900)),
          icon: const Icon(Icons.add_circle, color: Colors.black),
        ),
      ),

      body: Column(
        children: <Widget>[
          _buildSearchAndFilterRow(),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildCloudList(),
                _buildLocalList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Container(
      color: mahogany.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              onChanged: (String v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "ፈልግ (Search title or lyrics)...",
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: Icon(Icons.search, color: goldAccent),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildDynamicFilterChips(),
        ],
      ),
    );
  }

  Widget _buildDynamicFilterChips() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('app_config').doc('rhythms').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
        final List<String> rhythms = <String>["All"];
        if (snap.hasData && snap.data!.exists) {
          rhythms.addAll(List<String>.from(snap.data!['list'] ?? <String>[]));
        }

        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: rhythms.length,
            itemBuilder: (BuildContext context, int i) {
              final bool isSelected = _selectedFilter == rhythms[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(rhythms[i]),
                  selected: isSelected,
                  onSelected: (bool selected) => setState(() => _selectedFilter = rhythms[i]),
                  selectedColor: goldAccent,
                  backgroundColor: shelfOak,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCloudList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('songs').orderBy('updatedAt', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator(color: goldAccent));
        }
        
        final List<QueryDocumentSnapshot> filteredDocs = snap.data!.docs.where((QueryDocumentSnapshot doc) {
          final String title = doc['title'].toString().toLowerCase();
          final String lyrics = doc['lyrics'].toString().toLowerCase();
          final String style = doc['rhythmStyle'] ?? "Other";

          final bool matchesSearch = title.contains(_searchQuery) || lyrics.contains(_searchQuery);
          final bool matchesFilter = (_selectedFilter == "All") || (style == _selectedFilter);

          return matchesSearch && matchesFilter;
        }).toList();

        if (filteredDocs.isEmpty) {
          return _emptyState("ምንም አልተገኘም", "(No matching mezmures)");
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 160),
            itemCount: filteredDocs.length,
            itemBuilder: (BuildContext context, int i) {
              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildBookSpine(filteredDocs[i], null, null),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLocalList() {
    final List<Map<String, dynamic>> filteredDrafts = localDrafts.where((Map<String, dynamic> draft) {
      final String title = draft['title'].toString().toLowerCase();
      return title.contains(_searchQuery);
    }).toList();

    if (filteredDrafts.isEmpty) {
      return _emptyState("ረቂቆች አልተገኙም", "(No drafts found)");
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 160),
      itemCount: filteredDrafts.length,
      itemBuilder: (BuildContext context, int i) => _buildBookSpine(null, filteredDrafts[i], i),
    );
  }

  Widget _buildBookSpine(DocumentSnapshot? doc, Map<String, dynamic>? draft, int? idx) {
    final bool isCloud = doc != null;
    final String title = isCloud ? doc['title'] : (draft!['title'].isEmpty ? "ያልተሰየመ ረቂቅ" : draft['title']);
    final String sub = isCloud ? (doc['rhythmStyle'] ?? "Standard") : "ያልተጠናቀቀ ረቂቅ";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: shelfOak,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
        border: Border(left: BorderSide(color: isCloud ? goldAccent : Colors.orangeAccent, width: 8)),
        boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(4, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(title, style: GoogleFonts.notoSansEthiopic(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Text(sub, style: TextStyle(color: isCloud ? goldAccent.withValues(alpha: 0.7) : Colors.white38, fontSize: 12)),
        trailing: Container(
          decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(8)),
          child: IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.black, size: 28),
            onPressed: () async {
              final bool? refresh = await Navigator.push(
                context, MaterialPageRoute<bool>(builder: (BuildContext context) => SongEditorPage(doc: doc, draftData: draft, draftIndex: idx))
              );
              if (refresh == true) {
                _loadDrafts();
              }
            }
          ),
        ),
        onLongPress: () => _confirmDelete(doc, idx),
      ),
    );
  }

  Widget _emptyState(String amh, String eng) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.search_off_rounded, size: 60, color: goldAccent.withValues(alpha: 0.1)),
        Text(amh, style: const TextStyle(color: Colors.white38)),
        Text(eng, style: const TextStyle(color: Colors.white24, fontSize: 12)),
      ],
    ),
  );

  void _confirmDelete(DocumentSnapshot? doc, int? idx) {
    showDialog(
      context: context, 
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: mahogany,
        title: const Text("ይሰረዝ?", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("ተመለስ", style: TextStyle(color: goldAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (doc != null) { 
                await doc.reference.delete(); 
              } else {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                final List<String> drafts = prefs.getStringList('local_drafts') ?? <String>[];
                drafts.removeAt(idx!);
                await prefs.setStringList('local_drafts', drafts);
                _loadDrafts();
              }
              // FIXED: Async context gap fix for Navigator.pop
              if (mounted) {
                Navigator.of(ctx).pop();
              }
            }, 
            child: const Text("አጥፋ"),
          )
        ],
      )
    );
  }
}