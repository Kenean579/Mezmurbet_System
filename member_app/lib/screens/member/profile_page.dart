import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Woody Theme Palette
    final Color woodDark = const Color(0xFF3E2723);
    final Color goldAccent = const Color(0xFFFFC107);
    final Color parchment = const Color(0xFFFDF5E6);

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: woodDark,
        elevation: 0,
        iconTheme: IconThemeData(color: goldAccent),
        title: Text("የእኔ መረጃ", 
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          }
          
          var data = snap.data!;
          String name = data.exists ? (data['name'] ?? "አባል") : "አባል";
          String role = data.exists ? (data['role'] ?? "member") : "member";

          return Column(
            children: [
              // 1. IDENTITY HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: woodDark,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: goldAccent,
                      child: Icon(Icons.person, size: 60, color: woodDark),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.email ?? "",
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 2. STATUS BADGE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.brown.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Colors.green[700]),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ሁኔታ (Account Status)", 
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(
                            role.toUpperCase() == "ADMIN" ? "አስተዳዳሪ (Admin)" : "የኳየር አባል (Member)",
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 3. CLEAN LOGOUT BUTTON
              Padding(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B1F1F), // Deep Red
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 65),
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  onPressed: () => _confirmLogout(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded),
                      const SizedBox(width: 10),
                      Text("ውጣ (SIGN OUT SESSION)", 
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("መውጣት ይፈልጋሉ?"),
        content: const Text("Are you sure you want to end your current session?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("አይ (NO)")),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Back to previous screen (Nav will handle the rest)
            }, 
            child: const Text("አዎ (YES)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}