import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../services/case_history.dart';
import '../services/notification_service.dart';
import '../utils/ui_utils.dart';

class ChatProviderScreen extends StatefulWidget {
  final Map<String, dynamic> providerData;

  const ChatProviderScreen({super.key, required this.providerData});

  @override
  State<ChatProviderScreen> createState() => _ChatProviderScreenState();
}

class _ChatProviderScreenState extends State<ChatProviderScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _currentUserId = AuthService().currentUser?.uid ?? 'unknown_user';
  final CaseService _caseService = CaseService();
  bool _isUploading = false;
  late String _chatRoomId;
  int _lastDocCount = 0;
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    final providerId = widget.providerData['uid'];
    final participants = [_currentUserId, providerId];
    participants.sort();
    _chatRoomId = participants.join('_');
  }

  void _sendMessage({String text = '', String imageUrl = ''}) async {
    if (text.isEmpty && imageUrl.isEmpty) return;

    _messageController.clear();
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
        'text': text,
        'imageUrl': imageUrl,
        'senderId': _currentUserId,
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
        String fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        
        String downloadUrl = await _caseService.uploadEvidence(file, fileName);
        if (downloadUrl.isNotEmpty) {
          _sendMessage(imageUrl: downloadUrl);
        } else {
          if (mounted) {
            UIUtils.showCustomPopup(context, title: 'Upload Failed', message: 'Could not upload image.', isSuccess: false);
          }
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFCD7F32),
              child: Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.providerData['name'] ?? 'Service Provider',
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32)));
                }
                if (snapshot.hasError) return const Center(child: Text('Error loading messages.'));
                
                final docs = snapshot.data?.docs ?? [];
                
                // Notification Logic
                if (!_firstLoad && docs.length > _lastDocCount) {
                  final newest = docs.first.data() as Map<String, dynamic>;
                  if (newest['senderId'] != _currentUserId) {
                    NotificationService().showNotification(
                      id: DateTime.now().millisecond,
                      title: widget.providerData['name'] ?? 'Service Provider',
                      body: newest['text'] != null && newest['text'].isNotEmpty ? newest['text'] : 'Sent an attachment',
                    );
                  }
                }
                _lastDocCount = docs.length;
                _firstLoad = false;

                if (docs.isEmpty) return const Center(child: Text("Say hi to your verified Service Provider...", style: TextStyle(color: Colors.black54)));

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = (data['senderId'] == _currentUserId);
                    
                    String timeStr = '';
                    if (data['timestamp'] != null) {
                      final ts = (data['timestamp'] as Timestamp).toDate();
                      timeStr = '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
                    }

                    return _MessageBubble(
                      text: data['text'] ?? '',
                      imageUrl: data['imageUrl'] ?? '',
                      isMe: isMe,
                      time: timeStr,
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading) const LinearProgressIndicator(color: Color(0xFFCD7F32)),
          _MessageInputBar(
            controller: _messageController,
            onSend: () => _sendMessage(text: _messageController.text.trim()),
            onPickImage: _pickAndUploadImage,
            onCallTap: () {
              Navigator.pushNamed(context, '/call_screen');
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final String imageUrl;
  final bool isMe;
  final String time;

  const _MessageBubble({required this.text, this.imageUrl = '', required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFCD7F32).withOpacity(0.2) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.startsWith('local://') 
                    ? Image.file(File(imageUrl.replaceFirst('local://', '')), height: 150, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            if (text.isNotEmpty)
              Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done, size: 14, color: Colors.grey),
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
  final VoidCallback onPickImage;
  final VoidCallback onCallTap;

  const _MessageInputBar({required this.controller, required this.onSend, required this.onPickImage, required this.onCallTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onCallTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 14, backgroundColor: Color(0xFFCD7F32), child: Icon(Icons.phone, size: 14, color: Colors.white)),
                      SizedBox(width: 8),
                      Text('Make a Call', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey), onPressed: onPickImage),
                IconButton(icon: const Icon(Icons.image_outlined, color: Colors.grey), onPressed: onPickImage),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade300)),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(hintText: 'Message', border: InputBorder.none, hintStyle: TextStyle(color: Colors.black38)),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFFCD7F32)), onPressed: onSend),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
