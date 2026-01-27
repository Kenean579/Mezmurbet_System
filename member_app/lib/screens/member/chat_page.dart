import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For formatting time

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  String _userName = "Member";

  // Woody Theme Palette
  final Color woodDark = const Color(0xFF3E2723);
  final Color goldAccent = const Color(0xFFFFC107);
  final Color parchment = const Color(0xFFFDF5E6);

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _getUserName() async {
    final DocumentSnapshot userDoc = 
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (userDoc.exists) {
      final Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      setState(() => _userName = data['name'] ?? "አባል (Member)");
    }
  }

  // --- CRUD: DELETE MESSAGE ---
  void _deleteMessage(String msgId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_uid)
        .collection('messages')
        .doc(msgId)
        .delete();
  }

  // --- CRUD: EDIT MESSAGE ---
  void _editMessage(String msgId, String currentText) {
    final TextEditingController editCtrl = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: woodDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("መልእክት ያስተካክሉ (Edit Message)", 
          style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: editCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ሰርዝ")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: goldAccent),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_uid)
                  .collection('messages')
                  .doc(msgId)
                  .update({'text': editCtrl.text.trim()});
              if (mounted) Navigator.pop(context);
            },
            child: const Text("ቀይር", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: woodDark,
        elevation: 10,
        iconTheme: IconThemeData(color: goldAccent),
        title: Text("የእርዳታ መስመር (Support)", 
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 1. CHAT MESSAGES STREAM
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_uid)
                  .collection('messages')
                  .orderBy('ts', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.brown));
                
                final List<QueryDocumentSnapshot> docs = snap.data!.docs;

                return ListView.builder(
                  reverse: true, // Matches Admin Chat feel
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final Map<String, dynamic> m = docs[i].data() as Map<String, dynamic>;
                    final bool isMe = m['sender'] == 'user';
                    
                    // Format Timestamp
                    final DateTime? ts = (m['ts'] as Timestamp?)?.toDate();
                    final String timeStr = ts != null ? DateFormat('hh:mm a').format(ts) : "...";

                    return GestureDetector(
                      onLongPress: isMe ? () => _showOptions(docs[i].id, m['text'] ?? "") : null,
                      child: _buildMessageBubble(m['text'] ?? "", isMe, timeStr),
                    );
                  },
                );
              },
            ),
          ),

          // 2. INPUT AREA
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF5D4037) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(15),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              border: isMe ? null : Border.all(color: Colors.brown.withOpacity(0.1)),
            ),
            child: Text(text, 
              style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showOptions(String msgId, String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: parchment,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("አስተካክል (Edit)"),
            onTap: () { Navigator.pop(context); _editMessage(msgId, text); },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("አጥፋ (Delete)"),
            onTap: () { Navigator.pop(context); _deleteMessage(msgId); },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: "መልእክት እዚህ ይጻፉ... (Write here)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: woodDark,
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: goldAccent),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    String text = _msgController.text.trim();

    // 1. Update parent doc for Admin sorting
    FirebaseFirestore.instance.collection('chats').doc(_uid).set({
      'userId': _uid,
      'userName': _userName,
      'lastMsg': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Add message to sub-collection
    FirebaseFirestore.instance.collection('chats').doc(_uid).collection('messages').add({
      'text': text,
      'sender': 'user',
      'ts': FieldValue.serverTimestamp(),
    });

    _msgController.clear();
  }
}