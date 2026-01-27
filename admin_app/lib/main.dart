import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/onboarding_page.dart';

void main() async {
  // Ensure Flutter framework is ready
  WidgetsFlutterBinding.ensureInitialized();

  // FIX FOR THE LOG ISSUE: [core/duplicate-app]
  // This logic checks if Firebase is already running before attempting to start it.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase Initialized Successfully");
    } else {
      Firebase.app(); // Use the existing initialized instance
    }
  } catch (e) {
    debugPrint("Firebase Initialization Note: $e");
  }

  // SYSTEM UI STYLING: Make the status bar match the Mahogany theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent so the AppBar color shows through
    statusBarIconBrightness: Brightness.light, // White icons for dark background
    systemNavigationBarColor: Color(0xFF2B1B17), // Deep Wood for navigation bar
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MezmurbetAdminApp());
}

class MezmurbetAdminApp extends StatelessWidget {
  const MezmurbetAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // High-Contrast Woody Palette Definitions
    const Color woodDark = Color(0xFF3E2723); // Mahogany
    const Color goldAccent = Color(0xFFFFC107); // Pure Gold
    const Color parchment = Color(0xFFFDF5E6); // High-visibility background
    const Color oakPrimary = Color(0xFF5D4037); // Rich Wood

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mezmurbet Admin Hub',
      
      
      // PROFESSIONAL THEME ENGINE
      theme: ThemeData(
        useMaterial3: true,
        // Using a high-contrast color scheme to avoid "dusty" or muted colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: oakPrimary,
          primary: woodDark,
          secondary: goldAccent,
          surface: parchment,
          brightness: Brightness.light,
        ),
        
        // AMHARIC & ENGLISH TYPOGRAPHY
        textTheme: GoogleFonts.philosopherTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: woodDark,
          displayColor: woodDark,
        ),

        // HIGH-CONTRAST APP BAR STYLE (Mahogany and Gold)
        appBarTheme: const AppBarTheme(
          backgroundColor: woodDark,
          foregroundColor: goldAccent,
          centerTitle: true,
          elevation: 15,
          shadowColor: Colors.black,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          iconTheme: IconThemeData(color: goldAccent, size: 28),
        ),

        // CLEAN BUTTON THEMES
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: woodDark,
            foregroundColor: goldAccent,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // HIGH VISIBILITY INPUT FIELDS
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: oakPrimary, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: oakPrimary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: goldAccent, width: 2),
          ),
        ),
      ),
      
      // Initial Launch Screen
      home: const OnboardingPage(),
    );
  }
}