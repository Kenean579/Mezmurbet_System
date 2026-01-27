import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart'; // REQUIRED: Add 'intl' to pubspec.yaml
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; 
import '../../services/favorites_service.dart';

class LyricsReaderPage extends StatefulWidget {
  final DocumentSnapshot doc;
  const LyricsReaderPage({super.key, required this.doc});

  @override
  State<LyricsReaderPage> createState() => _LyricsReaderPageState();
}

class _LyricsReaderPageState extends State<LyricsReaderPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _fontSize = 22.0;
  bool _isFavorite = false;
  bool _isDownloading = false; 

  // Woody Theme Palette
  final Color woodDark = const Color(0xFF3E2723); 
  final Color goldAccent = const Color(0xFFFFC107);
  final Color parchment = const Color(0xFFFEF9E7);

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); 
    _loadFavStatus();
    _setupAudio();
  }

  void _setupAudio() async {
    final Map<String, dynamic>? data = widget.doc.data() as Map<String, dynamic>?;
    final String? url = data?['audioUrl'];
    
    if (url != null && url.isNotEmpty) {
      try {
        setState(() => _isDownloading = true);
        final file = await DefaultCacheManager().getSingleFile(url);
        await _audioPlayer.setFilePath(file.path);
        if (mounted) setState(() => _isDownloading = false);
      } catch (e) {
        try {
          await _audioPlayer.setUrl(url);
        } catch (_) {}
        if (mounted) setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _loadFavStatus() async {
    final bool isFav = await FavoritesService.isFavorite(widget.doc.id);
    if (!mounted) return;
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    final bool newStatus = await FavoritesService.toggleFavorite(widget.doc.id);
    if (!mounted) return;
    setState(() => _isFavorite = newStatus);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: woodDark,
        behavior: SnackBarBehavior.floating,
        content: Text(_isFavorite ? "ወደ ተመረጡ ተጨምሯል" : "ከተመረጡ ወጥቷል"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- NEW: SHOW SONG DETAILS SHEET ---
  void _showSongDetails(Map<String, dynamic> data) {
    // Format the timestamp from Firebase
    String formattedDate = "ያልታወቀ (Unknown)";
    if (data['updatedAt'] != null) {
      DateTime dt = (data['updatedAt'] as Timestamp).toDate();
      formattedDate = DateFormat('y-MM-dd (hh:mm a)').format(dt);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: parchment,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: goldAccent, width: 2),
        ),
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: woodDark.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Text("የመዝሙር መረጃ (Details)", style: GoogleFonts.philosopher(fontSize: 22, fontWeight: FontWeight.bold, color: woodDark)),
              const Divider(color: Colors.brown),
              
              _detailRow(Icons.title, "ርዕስ (Title)", data['title']),
              _detailRow(Icons.tune, "ስልት (Rhythm)", data['rhythmStyle']),
              _detailRow(Icons.update, "ለመጨረሻ ጊዜ የተስተካከለው", formattedDate),
              
              const SizedBox(height: 10),
              const Text("ተጨማሪ መረጃዎች (Attributes):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 5),

              // DYNAMIC ATTRIBUTES (Writer, Album, etc.)
              if (data['customFields'] != null)
                ... (data['customFields'] as Map).entries.map((e) => _detailRow(Icons.label_important_outline, e.key, e.value)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.brown),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.notoSansEthiopic(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "${value ?? 'N/A'}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = widget.doc.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: woodDark,
      appBar: AppBar(
        backgroundColor: woodDark,
        elevation: 0,
        iconTheme: IconThemeData(color: goldAccent),
        title: Text(
          data['title'] ?? "የመዝሙር ንባብ",
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border, color: goldAccent),
            onPressed: _toggleFavorite,
          ),
          // --- NEW: 3-DOT ICON ---
          IconButton(
            icon: Icon(Icons.more_vert, color: goldAccent),
            onPressed: () => _showSongDetails(data),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: parchment,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15)],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _zoomCircle(Icons.add, () => setState(() => _fontSize += 2)),
                        const SizedBox(width: 10),
                        _zoomCircle(Icons.remove, () => setState(() => _fontSize -= 2)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data['lyrics'] ?? "",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: _fontSize,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          if (data['audioUrl'] != null && data['audioUrl'] != "")
            _buildAdvancedPlayer(),
        ],
      ),
    );
  }

  Widget _zoomCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: woodDark.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: woodDark),
      ),
    );
  }

  Widget _buildAdvancedPlayer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
      decoration: BoxDecoration(
        color: woodDark,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _audioPlayer.duration ?? Duration.zero;
              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: goldAccent,
                      activeTrackColor: goldAccent,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble(),
                      value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                      onChanged: (value) => _audioPlayer.seek(Duration(milliseconds: value.toInt())),
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 32), onPressed: () => _audioPlayer.seek(Duration(seconds: _audioPlayer.position.inSeconds - 10))),
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  if (_isDownloading) return CircularProgressIndicator(color: goldAccent);
                  return GestureDetector(
                    onTap: () => playing ? _audioPlayer.pause() : _audioPlayer.play(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: goldAccent, shape: BoxShape.circle),
                      child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: woodDark, size: 40),
                    ),
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 32), onPressed: () => _audioPlayer.seek(Duration(seconds: _audioPlayer.position.inSeconds + 10))),
            ],
          ),
        ],
      ),
    );
  }
}