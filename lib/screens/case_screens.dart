import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/case_history.dart';
import 'call_screen.dart';

// ─────────────────────────────────────────────
// CASE CHAT SCREEN
// ─────────────────────────────────────────────
class CaseChatScreen extends StatefulWidget {
  final CaseModel caseModel;

  const CaseChatScreen({super.key, required this.caseModel});

  @override
  State<CaseChatScreen> createState() => _CaseChatScreenState();
}

class _CaseChatScreenState extends State<CaseChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.caseModel.id == null) return;
    
    _messageController.clear();
    FocusScope.of(context).unfocus(); // optional

    try {
      await FirebaseFirestore.instance
          .collection('cases')
          .doc(widget.caseModel.id)
          .collection('messages')
          .add({
        'text': text,
        // Assuming 'isMe' is true since the user is sending from this device
        'isMe': true,
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat with Officer',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Incident Card ──
          _IncidentCard(caseModel: widget.caseModel),

          // ── Messages ──
          Expanded(
            child: widget.caseModel.id == null 
              ? const Center(child: Text("Case ID is missing"))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cases')
                      .doc(widget.caseModel.id)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4793A)));
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading messages.'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    
                    if (docs.isEmpty) {
                      return const Center(child: Text("No messages yet. Send a message below."));
                    }

                    return ListView.builder(
                      reverse: true, // we query descending: true
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final text = data['text'] ?? '';
                        final isMe = data['isMe'] ?? false;
                        
                        // Parse timestamp
                        String timeStr = '';
                        if (data['timestamp'] != null) {
                          final ts = (data['timestamp'] as Timestamp).toDate();
                          timeStr = '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
                        }

                        return _MessageBubble(
                          text: text,
                          isMe: isMe,
                          time: timeStr,
                        );
                      },
                    );
                  },
              ),
          ),

          // ── Input Bar ──
          _MessageInputBar(
            controller: _messageController,
            onSend: _sendMessage,
            onCallTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CallScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final CaseModel caseModel;
  const _IncidentCard({required this.caseModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCD7F32), // Bronze matching main theme
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseModel.incidentNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caseModel.date,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  caseModel.caseType,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  caseModel.status,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          // Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Officer Assigned',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.70,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFC8F0C0) : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 12, color: Colors.blue.shade400),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCallTap;

  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // "Make a Call" button row
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onCallTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFCD7F32), // Bronze
                        child: Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Make a Call',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Text field bar
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.image_outlined, color: Colors.grey),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFCD7F32)),
                  onPressed: onSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
