import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AttributeManagerPage extends StatelessWidget {
  const AttributeManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color woodDark = Color(0xFF3E2723);
    const Color goldAccent = Color(0xFFFFC107);
    const Color parchment = Color(0xFFFDF5E6);

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: woodDark,
        title: Text("ተጨማሪ መረጃዎች", style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "attribute_fab",
        backgroundColor: goldAccent,
        onPressed: () => _addNewField(context),
        icon: const Icon(Icons.add_box_rounded, color: Colors.black),
        label: const Text("አዲስ መረጃ ጨምር", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // USABILITY TIP FOR ADMIN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: woodDark.withValues(alpha: 0.1),
            child: const Text(
              "እዚህ ጋር በመዝሙር መመዝገቢያ ገጽ ላይ እንዲታዩ የሚፈልጓቸውን ተጨማሪ ሳጥኖች መጨመር ይችላሉ።\nለምሳሌ፦ 'የመዝሙር ደራሲ' ወይም 'የአልበም ስም'።",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: woodDark),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('app_config').doc('attributes').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData || !snap.data!.exists) return const Center(child: CircularProgressIndicator());
                
                List fields = snap.data!['fields'] ?? [];
                
                if (fields.isEmpty) {
                  return const Center(child: Text("ምንም ተጨማሪ መረጃ አልተመዘገበም"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: fields.length,
                  itemBuilder: (context, i) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: const Icon(Icons.star_outline, color: woodDark),
                      title: Text(fields[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("በመዝሙር መመዝገቢያ ላይ ይታያል"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        onPressed: () => _removeField(fields[i]),
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

  void _addNewField(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("የሚጨመረው መረጃ ስም"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "ለምሳሌ፦ 'የመዝሙሩ ደራሲ'"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ሰርዝ")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              FirebaseFirestore.instance.collection('app_config').doc('attributes').update({
                'fields': FieldValue.arrayUnion([{'name': controller.text.trim(), 'type': 'text'}])
              });
              Navigator.pop(context);
            },
            child: const Text("ጨምር"),
          )
        ],
      ),
    );
  }

  void _removeField(Map field) {
    FirebaseFirestore.instance.collection('app_config').doc('attributes').update({
      'fields': FieldValue.arrayRemove([field])
    });
  }
}