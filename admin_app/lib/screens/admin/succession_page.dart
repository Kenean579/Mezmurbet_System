import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessionPage extends StatelessWidget {
  const SuccessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // High-Contrast Woody Palette
    const Color woodDark = Color(0xFF3E2723); 
    const Color goldAccent = Color(0xFFFFC107);
    const Color parchment = Color(0xFFFDF5E6);

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: woodDark,
        elevation: 8,
        title: Text(
          "የአስተዳዳሪዎች ዝርዝር (LEADERS)",
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // USABILITY TIP: Plain language explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: woodDark.withValues(alpha: 0.05),
            child: Text(
              "ወደ 'Admin' የተቀየሩ አባላት ባላቸው መለያ ኮድ ወደዚህ መግቢያ ገጽ መግባት ይችላሉ።\n(Promoted Admins use their existing access code to enter this app.)",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansEthiopic(fontSize: 12, fontWeight: FontWeight.bold, color: woodDark),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                if (snap.hasError) return const Center(child: Text("Error loading data"));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: woodDark));

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 100),
                  itemCount: snap.data!.docs.length,
                  itemBuilder: (BuildContext context, int i) {
                    final QueryDocumentSnapshot uDoc = snap.data!.docs[i];
                    final Map<String, dynamic> data = uDoc.data() as Map<String, dynamic>;
                    
                    final String name = data.containsKey('name') ? data['name'] : "ያልተሰየመ አባል";
                    final String role = data.containsKey('role') ? data['role'] : "member";
                    final bool isAdmin = role.toLowerCase() == 'admin';

                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: isAdmin ? goldAccent : Colors.transparent, width: 2)
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: isAdmin ? Colors.red[900] : woodDark,
                          child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person_outline, color: Colors.white, size: 30),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(
                          isAdmin ? "አሁን አስተዳዳሪ ነው (Admin)" : "የኳየር አባል (Member)",
                          style: TextStyle(color: isAdmin ? Colors.red[800] : Colors.grey[600], fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAdmin ? Colors.grey[200] : goldAccent,
                            foregroundColor: Colors.black,
                            elevation: isAdmin ? 0 : 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          onPressed: () => _confirmRoleChange(context, uDoc, name, isAdmin),
                          child: Text(isAdmin ? "መብት አንሳ\n(DEMOTE)" : "መብት ስጥ\n(PROMOTE)",
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRoleChange(BuildContext context, QueryDocumentSnapshot doc, String name, bool isAdmin) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF3E2723),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(isAdmin ? "መብት ይነሳ? (DEMOTE)" : "አስተዳዳሪ ይሁን? (PROMOTE)", 
          style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
        content: Text(
          isAdmin 
          ? "በእርግጥ የ $nameን የአስተዳዳሪነት መብት መሻር ይፈልጋሉ?" 
          : "የ $nameን ስልጣን ወደ አስተዳዳሪነት መቀየር ይፈልጋሉ? ይህም አባል አሁን ባለው ኮድ ወደዚህ አድሚን ገጽ መግባት እንዲችል ያደርገዋል።",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ተመለስ (NO)", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
            onPressed: () async {
              // CRUD: Execute role switch
              await doc.reference.update({'role': isAdmin ? 'member' : 'admin'});
              
              if (!context.mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: isAdmin ? Colors.orange : Colors.green,
                content: Text(isAdmin ? "$name ወደ አባልነት ዝቅ ብሏል።" : "$name አሁን አስተዳዳሪ ሆኗል! ባላቸው ኮድ መግባት ይችላሉ።"),
              ));
            }, 
            child: const Text("አዎ አረጋግጥ (YES)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}