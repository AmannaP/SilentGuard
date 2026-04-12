import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/case_history.dart';
import '../widgets/chat_widgets.dart';

class AdminCaseChatScreen extends StatefulWidget {
  final CaseModel caseModel;
  const AdminCaseChatScreen({super.key, required this.caseModel});

  @override
  State<AdminCaseChatScreen> createState() => _AdminCaseChatScreenState();
}

class _AdminCaseChatScreenState extends State<AdminCaseChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isUploading = false;

  void _sendMessage({String text = '', String imageUrl = ''}) async {
    if (text.isEmpty && imageUrl.isEmpty) return;
    if (widget.caseModel.id == null) return;
    
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('cases')
          .doc(widget.caseModel.id)
          .collection('messages')
          .add({
        'text': text,
        'imageUrl': imageUrl,
        'senderRole': 'staff',
        'isMe': true, // On admin screen, admin is "me" (right side)
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to send message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD7F32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat with Victim',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Victim: ${widget.caseModel.victimName}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cases')
                  .doc(widget.caseModel.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("No messages yet. Start the conversation."));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final senderRole = data['senderRole'] ?? 'victim';
                    final isMe = senderRole == 'staff'; // Admin is the sender

                    String timeStr = '';
                    if (data['timestamp'] != null) {
                      final ts = (data['timestamp'] as Timestamp).toDate();
                      timeStr = '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
                    }

                    return UnifiedMessageBubble(
                      message: ChatMessage(
                        text: data['text'] ?? '',
                        imageUrl: data['imageUrl'] ?? '',
                        isMe: isMe,
                        time: timeStr,
                        senderLabel: isMe ? null : 'Victim',
                      ),
                    );
                  },
                );
              },
            ),
          ),
          UnifiedChatInputBar(
            controller: _messageController,
            isUploading: _isUploading,
            onSend: () => _sendMessage(text: _messageController.text.trim()),
            onPickImage: () {
               // Future: Add image upload for admin
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload coming soon for admin.')));
            },
            onCallTap: () {
               // Future: Direct call to victim
            },
          ),
        ],
      ),
    );
  }
}
