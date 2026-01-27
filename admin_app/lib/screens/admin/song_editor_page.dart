import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongEditorPage extends StatefulWidget {
  final DocumentSnapshot? doc;
  final Map<String, dynamic>? draftData;
  final int? draftIndex;

  const SongEditorPage({super.key, this.doc, this.draftData, this.draftIndex});

  @override
  State<SongEditorPage> createState() => _SongEditorPageState();
}

class _SongEditorPageState extends State<SongEditorPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _lyrics = TextEditingController();

  // Persistent controllers to fix the cursor jumping bug
  final Map<String, TextEditingController> _dynamicControllers =
      <String, TextEditingController>{};

  File? _selectedFile;
  String _currentAudioUrl = "";
  String? _rhythm;
  String? _chord;
  Map<String, dynamic> _dynamicDataValues = <String, dynamic>{};
  bool _isUploading = false;

  // High-Contrast Woody Palette
  final Color woodDark = const Color(0xFF2B1B17);
  final Color mahogany = const Color(0xFF3E2723);
  final Color goldAccent = const Color(0xFFFFC107);
  final Color parchment = const Color(0xFFFEF9E7);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.doc != null) {
      final Map<String, dynamic> data =
          widget.doc!.data() as Map<String, dynamic>;
      _title.text = data['title'] ?? "";
      _lyrics.text = data['lyrics'] ?? "";
      _currentAudioUrl = data['audioUrl'] ?? "";
      _rhythm = data['rhythmStyle'];
      _chord = data['chordClass'];
      _dynamicDataValues = Map<String, dynamic>.from(
        data['customFields'] ?? <String, dynamic>{},
      );
    } else if (widget.draftData != null) {
      _title.text = widget.draftData!['title'] ?? "";
      _lyrics.text = widget.draftData!['lyrics'] ?? "";
      _currentAudioUrl = widget.draftData!['audioUrl'] ?? "";
      _rhythm = widget.draftData!['rhythmStyle'];
      _chord = widget.draftData!['chordClass'];
      _dynamicDataValues = Map<String, dynamic>.from(
        widget.draftData!['customFields'] ?? <String, dynamic>{},
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _lyrics.dispose();
    _dynamicControllers.forEach(
      (String key, TextEditingController controller) => controller.dispose(),
    );
    super.dispose();
  }

  void _executeSave() async {
    _dynamicControllers.forEach((String key, TextEditingController controller) {
      _dynamicDataValues[key] = controller.text;
    });

    final bool isComplete =
        _title.text.trim().isNotEmpty &&
        _lyrics.text.trim().isNotEmpty &&
        _rhythm != null;

    if (!isComplete) {
      _saveToLocalWorkroom();
    } else {
      _uploadAndPublish();
    }
  }

  Future<void> _saveToLocalWorkroom() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> drafts =
        prefs.getStringList('local_drafts') ?? <String>[];

    final Map<String, dynamic> draftMap = {
      'title': _title.text,
      'lyrics': _lyrics.text,
      'audioUrl': _currentAudioUrl,
      'rhythmStyle': _rhythm,
      'chordClass': _chord,
      'customFields': _dynamicDataValues,
    };

    if (widget.draftIndex != null) {
      drafts[widget.draftIndex!] = jsonEncode(draftMap);
    } else {
      drafts.add(jsonEncode(draftMap));
    }

    await prefs.setStringList('local_drafts', drafts);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.orange,
        content: Text("መረጃው አልተሟላም! ወደ 'ረቂቆች' ተቀምጧል።"),
      ),
    );
    Navigator.pop(context, true);
  }

  Future<void> _uploadAndPublish() async {
    setState(() => _isUploading = true);

    if (_selectedFile != null) {
      try {
        final http.MultipartRequest request = http.MultipartRequest(
          'POST',
          Uri.parse('https://catbox.moe/user/api.php'),
        );
        request.fields['reqtype'] = 'fileupload';
        request.files.add(
          await http.MultipartFile.fromPath(
            'fileToUpload',
            _selectedFile!.path,
          ),
        );
        final http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          _currentAudioUrl = (await response.stream.bytesToString()).trim();
        }
      } catch (e) {
        debugPrint("Upload failed: $e");
      }
    }

    final Map<String, dynamic> finalData = {
      'title': _title.text.trim(),
      'lyrics': _lyrics.text.trim(),
      'audioUrl': _currentAudioUrl,
      'rhythmStyle': _rhythm,
      'chordClass': _chord,
      'customFields': _dynamicDataValues,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (widget.doc == null) {
      await FirebaseFirestore.instance.collection('songs').add(finalData);
    } else {
      await widget.doc!.reference.update(finalData);
    }

    if (widget.draftIndex != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> drafts = prefs.getStringList('local_drafts') ?? <String>[];
      if (widget.draftIndex! < drafts.length) {
        drafts.removeAt(widget.draftIndex!);
        await prefs.setStringList('local_drafts', drafts);
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: woodDark,
      appBar: AppBar(
        backgroundColor: mahogany,
        elevation: 10,
        iconTheme: IconThemeData(color: goldAccent),
        title: Text(
          "መዝሙር አቀናባሪ | COMPOSER",
          style: GoogleFonts.philosopher(
            color: goldAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: goldAccent),
                  const SizedBox(height: 20),
                  const Text(
                    "በማስቀመጥ ላይ... (Syncing...)",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: parchment,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: goldAccent, width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Colors.black87, blurRadius: 20),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: <Widget>[
                    _buildTextInput(
                      _title,
                      "የመዝሙር ርዕስ (Song Title)",
                      Icons.title,
                    ),
                    const SizedBox(height: 15),
                    _buildTextInput(
                      _lyrics,
                      "ግጥም (Amharic Lyrics)",
                      Icons.format_quote,
                      isLong: true,
                    ),
                    const SizedBox(height: 15),
                    _buildAudioPickerUI(),
                    const SizedBox(height: 15),
                    _buildDropdownRow(),
                    const Divider(
                      height: 50,
                      color: Colors.brown,
                      thickness: 1,
                    ),
                    _buildDynamicAttributes(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isLong = false,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: isLong ? 10 : 1,
      style: GoogleFonts.notoSansEthiopic(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.w900,
        ),
        prefixIcon: Icon(icon, color: Colors.brown),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAudioPickerUI() {
    return InkWell(
      onTap: () async {
        // FIXED: Using FilePicker.platform.pickFiles() correctly
        try {
          final FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.audio,
            allowMultiple: false,
          );

          if (result != null && result.files.single.path != null) {
            setState(() {
              _selectedFile = File(result.files.single.path!);
            });
          }
        } catch (e) {
          debugPrint("File Picker Error: $e");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown),
          borderRadius: BorderRadius.circular(12),
          color: Colors.brown.withValues(alpha: 0.05),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.audiotrack,
              color: (_selectedFile != null || _currentAudioUrl.isNotEmpty)
                  ? Colors.green
                  : Colors.brown,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                _selectedFile != null
                    ? "ዜማ ተመርጧል (Audio Ready)"
                    : (_currentAudioUrl.isNotEmpty
                          ? "ዜማ ቀድሞ ተያይዟል (Linked)"
                          : "ዜማ ይምረጡ (Select Audio)"),
                style: const TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _dropField(
            'rhythms',
            "ስልት (Style)",
            _rhythm,
            (String? v) => setState(() => _rhythm = v),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dropField(
            'chords',
            "ክፍል (Class)",
            _chord,
            (String? v) => setState(() => _chord = v),
          ),
        ),
      ],
    );
  }

  Widget _dropField(
    String id,
    String label,
    String? cur,
    void Function(String?) onChg,
  ) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('app_config')
          .doc(id)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
        final List<dynamic> items = (snap.hasData && snap.data!.exists)
            ? snap.data!['list']
            : <dynamic>[];
        
        // Ensure the current value is valid for the items list
        final String? safeValue = items.contains(cur) ? cur : null;

        return DropdownButtonFormField<String>(
          dropdownColor: parchment,
          // FIXED: Use 'value' but ensure logic is robust
          value: safeValue,
          items: items
              .map(
                (dynamic e) => DropdownMenuItem<String>(
                  value: e.toString(),
                  child: Text(
                    e.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChg,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.brown, fontSize: 12),
          ),
        );
      },
    );
  }

  Widget _buildDynamicAttributes() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('app_config')
          .doc('attributes')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox();
        final List<dynamic> fields = snap.data!['fields'] ?? <dynamic>[];
        return Column(
          children: fields.map((dynamic f) {
            final String fieldName = f['name'].toString();
            if (!_dynamicControllers.containsKey(fieldName)) {
              _dynamicControllers[fieldName] = TextEditingController(
                text: _dynamicDataValues[fieldName] ?? "",
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 15),
              child: _buildTextInput(
                _dynamicControllers[fieldName]!,
                fieldName,
                Icons.star_border,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
        ),
        onPressed: _executeSave,
        child: const Text(
          "አስቀምጥ (SAVE TO SHELF)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}