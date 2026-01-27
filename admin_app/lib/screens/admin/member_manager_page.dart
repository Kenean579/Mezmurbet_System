import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class MemberManagerPage extends StatefulWidget {
  const MemberManagerPage({super.key});

  @override
  State<MemberManagerPage> createState() => _MemberManagerPageState();
}

class _MemberManagerPageState extends State<MemberManagerPage> {
  // Woody Theme Palette
  final Color woodDark = const Color(0xFF3E2723);
  final Color mahogany = const Color(0xFF2B1B17);
  final Color goldAccent = const Color(0xFFFFC107);
  final Color paper = const Color(0xFFFDF5E6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      appBar: AppBar(
        backgroundColor: woodDark,
        elevation: 10,
        title: Text("የኳየር አባላት (DIRECTORY)",
            style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 95),
        child: FloatingActionButton.extended(
          heroTag: "member_manager_fab",
          backgroundColor: goldAccent,
          onPressed: () => _inviteNewMember(context),
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.black),
          label: const Text("አዲስ አባል (INVITE)",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('name').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (snap.hasError) return const Center(child: Text("Error loading directory"));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.brown));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 150),
            itemCount: snap.data!.docs.length,
            itemBuilder: (BuildContext context, int i) {
              final QueryDocumentSnapshot uDoc = snap.data!.docs[i];
              final Map<String, dynamic> data = uDoc.data() as Map<String, dynamic>;

              final String name = data.containsKey('name') ? data['name'] : "ያልተሰየመ አባል";
              final String role = data.containsKey('role') ? data['role'] : "member";
              final String savedCode = data.containsKey('accessCode') ? data['accessCode'] : "N/A";
              final bool isActive = data.containsKey('isActive') ? data['isActive'] : true;
              final bool isAdmin = role.toLowerCase() == 'admin';

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border(left: BorderSide(color: isAdmin ? const Color.fromARGB(255, 181, 72, 64) : woodDark, width: 8)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? const Color.fromARGB(255, 122, 39, 33) : woodDark,
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Text("Code: $savedCode", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteUser(uDoc, name),
                      ),
                      Switch(
                          value: isActive,
                          activeColor: Colors.green,
                          onChanged: (bool v) => uDoc.reference.update({'isActive': v})),
                    ],
                  ),
                  onTap: () => _showRecoveryDialog(context, name, savedCode),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- STYLED ERROR PROMPT (Premium Look) ---
  void _showWoodyError(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: mahogany,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: goldAccent, width: 2)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("እሺ (OK)", style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _confirmDeleteUser(DocumentSnapshot doc, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: woodDark,
        title: const Text("አባል ይሰረዝ?", style: TextStyle(color: Colors.white)),
        content: Text("$nameን ከስርዓቱ በቋሚነት ማጥፋት ይፈልጋሉ?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("አይ", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await doc.reference.delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("አጥፋ (DELETE)"),
          ),
        ],
      ),
    );
  }

  // --- INVITE LOGIC WITH HIGH-CONTRAST INPUTS ---
  void _inviteNewMember(BuildContext context) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController emailCtrl = TextEditingController();
    final String generatedOtp = "CSFB-${Random().nextInt(90000) + 10000}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: woodDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: BorderSide(color: goldAccent, width: 1)),
        title: Text("አዲስ አባል መመዝገቢያ", 
          style: GoogleFonts.notoSansEthiopic(color: goldAccent, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FULL NAME INPUT
              _buildModernInput(nameCtrl, "ሙሉ ስም (Full Name)", Icons.person_outline),
              const SizedBox(height: 15),
              // EMAIL INPUT
              _buildModernInput(emailCtrl, "ኢሜይል (Email Address)", Icons.email_outlined),
              
              const SizedBox(height: 25),
              
              // ACCESS CODE DISPLAY
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Text("መግቢያ ኮድ (ACCESS CODE)", 
                      style: TextStyle(color: goldAccent.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 5),
                    Text(generatedOtp, 
                      style: GoogleFonts.sourceCodePro(color: goldAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ሰርዝ", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: Colors.black),
            onPressed: () async {
              String email = emailCtrl.text.trim();
              String name = nameCtrl.text.trim();

              if (name.isEmpty) { _showWoodyError("ስም አልተገኘም", "እባክዎ ስም ያስገቡ"); return; }
              if (!email.contains("@")) { _showWoodyError("ኢሜይል ስህተት", "ትክክለኛ ኢሜይል ያስገቡ"); return; }

              final FirebaseApp app = await Firebase.initializeApp(name: 'RegisterInstance', options: Firebase.app().options);
              try {
                final UserCredential res = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: generatedOtp);
                await FirebaseFirestore.instance.collection('users').doc(res.user!.uid).set({
                  'name': name, 'role': 'member', 'isActive': true, 'email': email.toLowerCase(), 'uid': res.user!.uid, 'accessCode': generatedOtp,
                });
                await app.delete();
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("በስኬት ተመዝግቧል!")));
              } catch (e) {
                _showWoodyError("ምዝገባው አልተሳካም", e.toString());
              }
            },
            child: const Text("አባል ፍጠር", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Helper for Dark/Woody Inputs
  Widget _buildModernInput(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: goldAccent),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: goldAccent)),
      ),
    );
  }

  void _showRecoveryDialog(BuildContext context, String name, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: woodDark,
        title: Text("$name - Access Code", style: TextStyle(color: goldAccent)),
        content: SelectableText(code, textAlign: TextAlign.center, style: GoogleFonts.sourceCodePro(color: goldAccent, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE", style: TextStyle(color: Colors.white38)))],
      ),
    );
  }
}