import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color woodDark = Color(0xFF3E2723);
    const Color goldAccent = Color(0xFFFFC107);
    const Color parchment = Color(0xFFFDF5E6);

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: woodDark,
        title: Text("የእርዳታ መልእክቶች (SUPPORT)", 
          style: GoogleFonts.philosopher(color: goldAccent, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text("Error loading chats"));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: woodDark));
          if (snap.data!.docs.isEmpty) return const Center(child: Text("ምንም መልእክት የለም (Empty Inbox)"));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              var chat = snap.data!.docs[i];
              Map<String, dynamic> data = chat.data() as Map<String, dynamic>;
              
              String name = data['userName'] ?? "አባል (Member)";
              String lastMsg = data['lastMsg'] ?? "";
              DateTime? time = (data['lastUpdated'] as Timestamp?)?.toDate();
              String timeStr = time != null ? DateFormat('hh:mm a').format(time) : "";

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: woodDark,
                    child: Icon(Icons.person, color: goldAccent),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatDetailPage(chatId: chat.id, userName: name)
                  )),
                ),
              );
            }
          );
        }
      ),
    );
  }
}