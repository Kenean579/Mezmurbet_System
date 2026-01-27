import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String userName;
  const ChatDetailPage({super.key, required this.chatId, required this.userName});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _adminMsgController = TextEditingController();
  final Color woodDark = const Color(0xFF3E2723);
  final Color goldAccent = const Color(0xFFFFC107);
  final Color parchment = const Color(0xFFFDF5E6);

  @override
  void dispose() {
    _adminMsgController.dispose();
    super.dispose();
  }

  // --- CRUD: DELETE MESSAGE ---
  void _deleteMessage(String msgId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(msgId)
        .delete();
  }

  // --- CRUD: EDIT MESSAGE ---
  void _editMessage(String msgId, String currentText) {
    final editController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("መልእክት ይቀይሩ (Edit)"),
        content: TextField(controller: editController, maxLines: null),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ሰርዝ (Cancel)")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .doc(msgId)
                  .update({'text': editController.text.trim()});
              Navigator.pop(context);
            },
            child: const Text("ቀይር (Update)"),
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
        title: Text(widget.userName, style: GoogleFonts.philosopher(fontWeight: FontWeight.bold, color: goldAccent)),
        backgroundColor: woodDark,
        elevation: 10,
        iconTheme: IconThemeData(color: goldAccent),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('ts', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: snap.data!.docs.length,
                  itemBuilder: (context, i) {
                    var mDoc = snap.data!.docs[i];
                    Map<String, dynamic> m = mDoc.data() as Map<String, dynamic>;
                    bool isAdm = m['sender'] == 'admin';
                    
                    DateTime? ts = (m['ts'] as Timestamp?)?.toDate();
                    String timeStr = ts != null ? DateFormat('HH:mm').format(ts) : "...";

                    return GestureDetector(
                      // Admins can manage their own messages or user messages
                      onLongPress: () {
                        _showOptions(mDoc.id, m['text'] ?? "");
                      },
                      child: _buildMessageBubble(m['text'] ?? "", isAdm, timeStr),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isAdm, String time) {
    return Align(
      alignment: isAdm ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isAdm ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isAdm ? woodDark : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: isAdm ? const Radius.circular(15) : Radius.zero,
                bottomRight: isAdm ? Radius.zero : const Radius.circular(15),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              border: isAdm ? null : Border.all(color: Colors.brown.withOpacity(0.1)),
            ),
            child: Text(
              text,
              style: TextStyle(color: isAdm ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showOptions(String msgId, String text) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("ቀይር (Edit)"),
            onTap: () { Navigator.pop(context); _editMessage(msgId, text); },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("አጥፋ (Delete)"),
            onTap: () { Navigator.pop(context); _deleteMessage(msgId); },
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _adminMsgController,
              decoration: const InputDecoration(hintText: "መልስ ይጻፉ (Reply)...", border: InputBorder.none),
            ),
          ),
          CircleAvatar(
            backgroundColor: woodDark,
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: goldAccent),
              onPressed: () {
                if (_adminMsgController.text.isEmpty) return;
                String val = _adminMsgController.text.trim();
                
                FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
                  'text': val,
                  'sender': 'admin', // ID is anonymous role
                  'ts': FieldValue.serverTimestamp(),
                });

                FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
                  'lastMsg': val,
                  'lastUpdated': FieldValue.serverTimestamp(),
                });
                _adminMsgController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}
