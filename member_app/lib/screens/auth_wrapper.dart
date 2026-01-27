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
        // 1. Check if user is logged in
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.brown)));
        }

        if (snapshot.hasData && snapshot.data != null) {
          // 2. Security Check: Is the member active? (Requirement: Admin can revoke access)
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).snapshots(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userSnap.hasData && userSnap.data!.exists) {
                bool isActive = userSnap.data!['isActive'] ?? true;
                if (isActive) {
                  return const MemberNavigation(); // Main App
                } else {
                  return _buildBlockedScreen();
                }
              }
              // If user is authenticated but no record exists in Firestore
              return const LoginPage();
            },
          );
        }

        // 3. Not logged in -> Show Login with OTP
        return const LoginPage();
      },
    );
  }

  Widget _buildBlockedScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_rounded, size: 100, color: Color(0xFF3E2723)),
              const SizedBox(height: 20),
              const Text(
                "ይቅርታ! መግቢያዎ ታግዷል።", // Access Blocked
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
              ),
              const SizedBox(height: 10),
              const Text(
                "እባክዎን የኳየር አስተዳዳሪውን ያነጋግሩ።\n(Contact Choir Admin for access)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.brown),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("ተመለስ (Logout)"),
              )
            ],
          ),
        ),
      ),
    );
  }
}