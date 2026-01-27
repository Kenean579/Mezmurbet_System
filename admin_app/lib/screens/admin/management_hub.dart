import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'metadata_manager_page.dart';
import 'attribute_manager_page.dart';
import 'succession_page.dart';

class ManagementHub extends StatelessWidget {
  const ManagementHub({super.key});

  @override
  Widget build(BuildContext context) {
    const Color woodDark = Color(0xFF3E2723);
    const Color goldAccent = Color(0xFFFFC107);
    const Color parchment = Color(0xFFFDF5E6);

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: woodDark,
        title: Text("ማስተካከያ (SYSTEM HUB)", 
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _buildTile(
            context, 
            "የመዝሙር ስልቶች (Rhythms)", 
            "ዋልዝ፣ ረጌ እና ሌሎች ስልቶችን ለመጨመር", 
            Icons.tune, 
            const MetadataManagerPage(docId: 'rhythms', title: 'Rhythm Styles')
          ),
          
          _buildTile(
            context, 
            "የመዝሙር ክፍሎች (Classes)", 
            "የመዝሙር ክፍሎችን (ለምሳሌ፦ 1ኛ ክፍል) ለመቀየር", 
            Icons.piano, 
            const MetadataManagerPage(docId: 'chords', title: 'Chord Classes')
          ),
          
          _buildTile(
            context, 
            "ተጨማሪ መረጃዎች (Extra Fields)", 
            "እንደ 'ደራሲ' ያሉ አዳዲስ የመረጃ ሳጥኖችን ለመጨመር", 
            Icons.playlist_add_circle, 
            const AttributeManagerPage()
          ),
          
          _buildTile(
            context, 
            "አስተዳዳሪዎችን መቀየር (Admins)", 
            "ሌሎች ሰዎችን የአፕሊኬሽኑ አስተዳዳሪ ለማድረግ", 
            Icons.gavel, 
            const SuccessionPage()
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String t, String sub, IconData i, Widget p) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 18),
      color: const Color(0xFF8D6E63), // Richer Wood Color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFC107),
          radius: 25,
          child: Icon(i, color: Colors.black),
        ),
        title: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute<void>(builder: (context) => p)
        ),
      ),
    );
  }
}