import 'package:flutter/material.dart';
import 'call_screen.dart';

void main() {
  runApp(const CaseScreens());
}

class CaseScreens extends StatelessWidget {
  const CaseScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Case Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4793A)),
        useMaterial3: true,
      ),
      home: const CaseDetailsPage(),
    );
  }
}

// ─────────────────────────────────────────────
// CASE DETAILS PAGE
// ─────────────────────────────────────────────
class CaseDetailsPage extends StatefulWidget {
  const CaseDetailsPage({super.key});

  @override
  State<CaseDetailsPage> createState() => _CaseDetailsPageState();
}

class _CaseDetailsPageState extends State<CaseDetailsPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Message here', 'isMe': false, 'time': '2:00pm'},
    {'text': 'Message here', 'isMe': true, 'time': '2:00pm'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Case Details',
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
          _IncidentCard(),

          // ── Messages ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _MessageBubble(
                  text: msg['text'],
                  isMe: msg['isMe'],
                  time: msg['time'],
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4793A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Incident No.1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '02/02/2026',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Rape Case',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  'Open',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
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
                'Help Desk Active',
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFFD4793A),
                        child: const Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
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
                  icon: const Icon(Icons.send, color: Color(0xFFD4793A)),
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
