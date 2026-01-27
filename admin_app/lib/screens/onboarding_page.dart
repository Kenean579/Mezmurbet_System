import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'auth_wrapper.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  // Woody High-Contrast Palette
  final Color woodDark = const Color(0xFF3E2723); // Mahogany
  final Color goldAccent = const Color(0xFFFFC107); // Pure Gold
  final Color paper = const Color(0xFFFDF5E6); // Parchment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: Stack(
        children: [
          // 1. PAGE VIEW CONTENT
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
            },
            children: [
              _buildSlide(
                icon: Icons.library_music_rounded,
                titleEn: "Digital Heritage",
                titleAm: "ዲጂታል ቅርሶች",
                descEn: "Organize the choir's songs and their lyrics on a professional digital app.",
                descAm: "የኳየሩን መዝሙሮች  በዲጂታል መልኩ ያደራጁ።",
              ),
              _buildSlide(
                icon: Icons.edit_note_rounded,
                titleEn: "Advanced Workroom For Choir's leader",
                titleAm: "ዘመናዊ የኳየር መሪዎች የሥራ ክፍል",
                descEn: "Save drafts locally and finalize mezmures when ready.",
                descAm: "ረቂቆችን በስልክዎ ላይ ያስቀምጡና ሲጨርሱ ለአባላቱ ያጋሩ።",
              ),
              _buildSlide(
                icon: Icons.admin_panel_settings_rounded,
                titleEn: "Leadership Control",
                titleAm: "የአመራር ቁጥጥር",
                descEn: "Manage multiple admins and ensure seamless continuity.",
                descAm: "አስተዳዳሪዎችን ያስተካክሉ ፣ የአመራር ቅብብሎሽንም ያረጋግጡ።",
              ),
            ],
          ),

          // 2. SKIP BUTTON (TOP RIGHT)
          if (!isLastPage)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () => _controller.jumpToPage(2),
                child: Text(
                  "SKIP / ዝለል",
                  style: TextStyle(
                    color: woodDark.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // 3. FOOTER NAVIGATION
          Container(
            alignment: const Alignment(0, 0.85),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: woodDark,
                    dotColor: woodDark.withValues(alpha: 0.2),
                    dotHeight: 10,
                    dotWidth: 10,
                    expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 50),
                isLastPage ? _buildFinishBtn() : _buildNextBtn(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String titleEn,
    required String titleAm,
    required String descEn,
    required String descAm,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with a high-contrast shadow circle
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: woodDark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Icon(icon, size: 80, color: goldAccent),
          ),
          const SizedBox(height: 50),
          
          // Bilingual Titles
          Text(
            titleAm,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: woodDark,
            ),
          ),
          Text(
            titleEn,
            style: GoogleFonts.philosopher(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: woodDark.withValues(alpha: 0.6),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Bilingual Descriptions
          Text(
            descAm,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 16,
              color: woodDark.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            descEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: woodDark.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextBtn() {
    return SizedBox(
      width: 150,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: woodDark,
          foregroundColor: goldAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("NEXT", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishBtn() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: Colors.black,
          elevation: 10,
          shadowColor: goldAccent.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: const Text(
          "ቀጥል (GET STARTED)",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}