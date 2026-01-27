import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'navigation_menu.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.brown)));
        }
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (userSnap.hasData && userSnap.data!.exists) {
                String role = userSnap.data!['role'] ?? 'member';
                bool isActive = userSnap.data!['isActive'] ?? true;
                if (role == 'admin' && isActive) return const AdminMainNavigation();
              }
              return _accessDenied();
            },
          );
        }
        return const AdminLoginPage();
      },
    );
  }

  Widget _accessDenied() => Scaffold(
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.gavel_rounded, size: 100, color: Color(0xFF3E2723)),
      const Text("ADMIN ACCESS ONLY", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const Padding(padding: EdgeInsets.all(20), child: Text("Your credentials do not permit entry.", textAlign: TextAlign.center)),
      ElevatedButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text("Log Out"))
    ])),
  );
}