import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math; // Required for 360-degree rotation

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animController;

  // Woody Palette
  final Color woodDark = const Color(0xFF3E2723); // Mahogany
  final Color goldAccent = const Color(0xFFFFC107); // Pure Gold
  final Color paper = const Color(0xFFFDF5E6); // Parchment

  @override
  void initState() {
    super.initState();
    // 1. INITIALIZE 360-DEGREE ROTATION
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 10)
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2. MODERN 3D ROTATING CROSS BADGE
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // 3D Perspective
                      ..rotateY(_animController.value * 2 * math.pi), // 360-degree rotation
                    child: _buildRotatingWoodyIcon(),
                  );
                },
              ),
              const SizedBox(height: 40),

              // 3. BILINGUAL BRANDING
              Text(
                "የመዝሙርቤት", 
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 38, 
                  fontWeight: FontWeight.w900, 
                  color: woodDark,
                  letterSpacing: -1
                )
              ),
              const Text(
                "BDU-CSF CHOIR DIGITAL SONGBOOK", 
                style: TextStyle(
                  letterSpacing: 2, 
                  color: Colors.brown, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 50),
              
              // 4. INPUT CARD
              _buildInputCard(),
              
              const SizedBox(height: 40),
              
              // 5. ACTION BUTTON
              _isLoading 
                ? CircularProgressIndicator(color: woodDark)
                : SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: woodDark,
                        foregroundColor: goldAccent,
                        elevation: 12,
                        shadowColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(color: goldAccent, width: 1),
                        ),
                      ),
                      onPressed: _handleLogin,
                      child: Text(
                        "ግባ (LOG IN TO SHELF)", 
                        style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          letterSpacing: 1.2
                        )
                      ),
                    ),
                  ),
              const SizedBox(height: 30),
              Text(
                "ባህር ዳር ዩኒቨርሲቲ ክርስቲያን ተማሪዎች ህብረት",
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 10,
                  color: Colors.brown.withValues(alpha: 0.5)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: THE 360 ROTATING WOODY ICON
  Widget _buildRotatingWoodyIcon() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: woodDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: goldAccent, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.add_rounded, color: goldAccent, size: 70), // The Cross
          Positioned(
            bottom: 15,
            right: 15,
            child: Icon(Icons.music_note_rounded, color: paper, size: 28), // Note Accent
          )
        ],
      ),
    );
  }

  // WIDGET: HIGH-CONTRAST INPUT CARD
  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: woodDark.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          _buildModernInput(
            _emailController, 
            "ኢሜይል (Email Address)", 
            Icons.alternate_email_rounded, 
            false
          ),
          const SizedBox(height: 20),
          _buildModernInput(
            _otpController, 
            "መግቢያ ኮድ (Access Code)", 
            Icons.vpn_key_rounded, 
            true
          ),
        ],
      ),
    );
  }

  Widget _buildModernInput(TextEditingController ctrl, String hint, IconData icon, bool isPass) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        prefixIcon: Icon(icon, color: woodDark),
        filled: true,
        fillColor: paper.withValues(alpha: 0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: woodDark.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: goldAccent, width: 2),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _otpController.text.isEmpty) {
      _showErrorSnackBar("እባክዎ መረጃውን በትክክል ያስገቡ");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _otpController.text.trim(), 
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar("ስህተት፡ ${e.message}");
    } catch (e) {
      _showErrorSnackBar("Login Failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}