import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe Firebase Initialization with Offline Persistence (Non-Functional Requirement)
  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      } else {
        // Let native Android/iOS initialization (from google-services.json / plist)
        // handle default options where available, avoids duplicate-app errors.
        await Firebase.initializeApp();
      }

      // Enable Offline Caching so the shelf works without internet in church
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  } on FirebaseException catch (e) {
    // Ignore duplicate-app errors if Firebase was already initialized natively.
    if (e.code == 'duplicate-app') {
      debugPrint('Firebase already initialized (native), continuing.');
    } else {
      debugPrint('Firebase Initialization Error: $e');
    }
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  runApp(const MezmurbetMemberApp());
}

class MezmurbetMemberApp extends StatelessWidget {
  const MezmurbetMemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      title: "Mezmurbet Member's Hub",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5D4037), // Oak/Wood Seed
        // High-contrast Spiritual Typography
        textTheme: GoogleFonts.philosopherTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFDF5E6), // Parchment White
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3E2723), // Mahogany
          foregroundColor: Color(0xFFFFC107), // Gold
          centerTitle: true,
          elevation: 0,
        ),
        // Modern Material 3 Navigation Bar styling
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFC107).withOpacity(0.3),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}