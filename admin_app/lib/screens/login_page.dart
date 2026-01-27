import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  late AnimationController _animController;
  bool _isLoading = false;

  final Color woodDark = const Color(0xFF3E2723); 
  final Color goldAccent = const Color(0xFFFFC107);
  final Color paper = const Color(0xFFFDF5E6);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 10)
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // MODERN PREMIUM ERROR PROMPT
  void _showWoodyError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: woodDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldAccent, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "ስህተት (Error): $message",
                  style: GoogleFonts.notoSansEthiopic(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showWoodyError("እባክዎ ሁሉንም ሳጥኖች ይሙሉ");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String readableError = "የተሳሳተ መረጃ";
      if (e.code == 'invalid-email') readableError = "ኢሜይሉ የተሳሳተ ነው (Bad Email)";
      if (e.code == 'user-not-found') readableError = "አካውንቱ አልተገኘም (No User)";
      if (e.code == 'wrong-password') readableError = "የይለፍ ቃሉ ተሳስቷል (Wrong Pass)";
      
      if (mounted) _showWoodyError(readableError);
    } catch (e) {
      if (mounted) _showWoodyError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) 
                      ..rotateY(_animController.value * 2 * math.pi),
                    child: _buildWoody3DIcon(),
                  );
                },
              ),
              const SizedBox(height: 40),

              Text(
                "መዝሙርቤት",
                style: GoogleFonts.philosopher(
                  fontSize: 42, fontWeight: FontWeight.bold, color: woodDark, letterSpacing: 2,
                ),
              ),
              Text(
                "ADMINISTRATOR APP",
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w800, color: woodDark.withValues(alpha: 0.6), letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 50),

              // LOGIN CARD
              _buildInputCard(),
              const SizedBox(height: 40),

              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF3E2723))
                  : SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: woodDark,
                          foregroundColor: goldAccent,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: goldAccent, width: 1),
                          ),
                        ),
                        onPressed: _login,
                        child: Text(
                          "ግቡ (LOGIN TO VAULT)",
                          style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              const SizedBox(height: 40),
              Text(
                "ባህር ዳር ዩኒቨርሲቲ ክርስቲያን ተማሪዎች ህብረት",
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 10, color: Colors.brown.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWoody3DIcon() {
    return Container(
      height: 120, width: 120,
      decoration: BoxDecoration(
        color: woodDark,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
        border: Border.all(color: goldAccent, width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.add_rounded, color: goldAccent, size: 70),
          Positioned(bottom: 15, right: 15, child: Icon(Icons.music_note_rounded, color: paper, size: 28))
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: woodDark.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _textField(controller: _emailController, label: "የአድሚን ኢሜይል (Admin Email)", icon: Icons.alternate_email_rounded),
          const SizedBox(height: 20),
          _textField(controller: _passController, label: "የይለፍ ቃል (Password)", icon: Icons.lock_person_rounded, isPass: true),
        ],
      ),
    );
  }

  Widget _textField({required TextEditingController controller, required String label, required IconData icon, bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
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
}