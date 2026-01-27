import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// REMOVED: unused shared_preferences import
import 'package:google_fonts/google_fonts.dart';
import 'lyrics_reader_page.dart';
import '../../services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Color woodDark = const Color(0xFF3E2723);
  final Color goldAccent = const Color(0xFFFFC107);
  final Color parchment = const Color(0xFFFDF5E6);

  Future<List<String>> _getFavoriteIds() async {
    return await FavoritesService.getFavoriteIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        title: Text(
          "የተመረጡ መዝሙራት", 
          style: GoogleFonts.philosopher(
            color: goldAccent, 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          )
        ),
        backgroundColor: woodDark,
        elevation: 10,
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _getFavoriteIds(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> favSnap) {
          if (favSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          }
          
          if (!favSnap.hasData || favSnap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.star_border_rounded, size: 100, color: woodDark.withValues(alpha: 0.1)),
                  const SizedBox(height: 15),
                  Text(
                    "ምንም የተመረጠ መዝሙር የለም", 
                    style: TextStyle(color: woodDark.withValues(alpha: 0.5), fontWeight: FontWeight.bold)
                  ),
                  const Text("(No favorites selected yet)", style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('songs').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> songSnap) {
              if (songSnap.hasError) return const Center(child: Text("Error connecting to Vault"));
              if (!songSnap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.brown));
              
              final List<QueryDocumentSnapshot> favorites = songSnap.data!.docs.where((QueryDocumentSnapshot d) {
                return favSnap.data!.contains(d.id);
              }).toList();

              if (favorites.isEmpty) {
                return const Center(child: Text("Starred songs were not found in the cloud."));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 120),
                itemCount: favorites.length,
                itemBuilder: (BuildContext context, int i) {
                  final QueryDocumentSnapshot song = favorites[i];
                  final Map<String, dynamic> data = song.data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border(left: BorderSide(color: goldAccent, width: 8)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: goldAccent.withValues(alpha: 0.2),
                        child: const Icon(Icons.stars_rounded, color: Colors.amber),
                      ),
                      title: Text(
                        data['title'] ?? "ያልተሰየመ", 
                        style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 17)
                      ),
                      subtitle: Text(
                        data['rhythmStyle'] ?? "Standard",
                        style: TextStyle(color: woodDark.withValues(alpha: 0.6), fontSize: 13)
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (BuildContext context) => LyricsReaderPage(doc: song)),
                        );
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}