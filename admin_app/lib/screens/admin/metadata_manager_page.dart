import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MetadataManagerPage extends StatelessWidget {
  final String docId, title;
  const MetadataManagerPage({super.key, required this.docId, required this.title});

  @override
  Widget build(BuildContext context) {
    // Styling Colors
    const Color woodDark = Color(0xFF3E2723);
    const Color goldAccent = Color(0xFFFFC107);
    const Color parchment = Color(0xFFFDF5E6);

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: woodDark,
        elevation: 10,
        title: Text(title, 
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "metadata_fab_$docId",
        backgroundColor: goldAccent,
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add_circle, color: Colors.black),
        label: const Text("አዲስ ጨምር (ADD NEW)", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // USABILITY HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: woodDark.withValues(alpha: 0.1),
            child: Text(
              "እዚህ ጋር በመዝሙር መመዝገቢያ ገጽ ላይ የሚታዩትን ምርጫዎች ማስተካከል ይችላሉ።",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 12, fontWeight: FontWeight.w600, color: woodDark),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('app_config').doc(docId).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
                if (snap.hasError) return const Center(child: Text("Error loading list"));
                if (!snap.hasData || !snap.data!.exists) return const Center(child: CircularProgressIndicator());
                
                final List<dynamic> list = snap.data!['list'] ?? [];
                
                if (list.isEmpty) {
                  return const Center(child: Text("ዝርዝሩ ባዶ ነው (The list is empty)"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 100),
                  itemCount: list.length,
                  itemBuilder: (context, i) => Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.label_important, color: woodDark),
                      title: Text(list[i].toString(), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, list[i].toString()),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    // --- LOGIC: Differentiated Hints ---
    String dynamicHint = "እዚህ ጋር ይጻፉ...";
    if (docId == 'rhythms') {
      dynamicHint = "ለምሳሌ፦ ዋልዝ (Waltz)";
    } else if (docId == 'chords') {
      dynamicHint = "ለምሳሌ፦ 1ኛ ክፍል (1st Class)";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("$title ጨምር"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: dynamicHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("ተመለስ", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723)),
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              FirebaseFirestore.instance.collection('app_config').doc(docId).update({
                'list': FieldValue.arrayUnion([controller.text.trim()])
              });
              Navigator.pop(context);
            },
            child: const Text("አስቀምጥ (SAVE)", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("ይሰረዝ?"),
        content: Text("'$item' ከዝርዝሩ ውስጥ እንዲጠፋ ይፈልጋሉ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("አይ")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('app_config').doc(docId).update({
                'list': FieldValue.arrayRemove([item])
              });
              Navigator.pop(context);
            },
            child: const Text("አዎ አጥፋ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}