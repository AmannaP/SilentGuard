import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../services/case_history.dart';
import '../utils/ui_utils.dart';
import '../widgets/chat_widgets.dart';
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
  final CaseService _caseService = CaseService();
  bool _isUploading = false;

  void _sendMessage({String text = '', String imageUrl = ''}) async {
    if (text.isEmpty && imageUrl.isEmpty) return;
    if (widget.caseModel.id == null) return;
    
    _messageController.clear();
    FocusScope.of(context).unfocus();

    try {
      await FirebaseFirestore.instance
          .collection('cases')
          .doc(widget.caseModel.id)
          .collection('messages')
          .add({
        'text': text,
        'imageUrl': imageUrl,
        // senderRole='victim' = user side; 'staff' = admin side
        // isMe is resolved per-viewer: victim sees own messages on right
        'senderRole': 'victim',
        'isMe': true, // kept for legacy backward-compat
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to send message: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        setState(() => _isUploading = true);

        File file = File(result.files.single.path!);
        String fileName = 'case_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        
        String downloadUrl = await _caseService.uploadEvidence(file, fileName);
        if (downloadUrl.isNotEmpty) {
          _sendMessage(imageUrl: downloadUrl);
        } else {
          if (mounted) UIUtils.showCustomPopup(context, title: 'Upload Failed', message: 'Could not upload image.', isSuccess: false);
        }
      }
    } catch (e) {
      if (mounted) UIUtils.showCustomPopup(context, title: 'Storage Error', message: e.toString(), isSuccess: false);
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                        // senderRole-aware: victim sees own msgs on right,
                        // staff messages appear on the left
                        final senderRole = data['senderRole'] ?? 'victim';
                        final isMe = senderRole == 'victim';
                        
                        // Parse timestamp
                        String timeStr = '';
                        if (data['timestamp'] != null) {
                          final ts = (data['timestamp'] as Timestamp).toDate();
                          timeStr = '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
                        }

                        return UnifiedMessageBubble(
                          message: ChatMessage(
                            text: text,
                            imageUrl: data['imageUrl'] ?? '',
                            isMe: isMe,
                            time: timeStr,
                            senderLabel: isMe ? null : 'Renel Ghana Staff',
                            caseTag: isMe ? null : widget.caseModel.incidentNumber,
                          ),
                        );
                      },
                    );
                  },
              ),
          ),

          if (_isUploading) const LinearProgressIndicator(color: Color(0xFFCD7F32)),

          // ── Input Bar ──
          UnifiedChatInputBar(
            controller: _messageController,
            isUploading: _isUploading,
            onSend: () => _sendMessage(text: _messageController.text.trim()),
            onPickImage: _pickAndUploadImage,
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

// Removed internal _MessageBubble and _MessageInputBar as they are now in chat_widgets.dart

