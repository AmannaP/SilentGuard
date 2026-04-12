import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/case_history.dart';
import '../services/notification_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/chat_widgets.dart';

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

  Future<void> _pickAndUploadImage({required bool fromCamera}) async {
    try {
      final picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (xFile != null) {
        if (!mounted) return;
        setState(() => _isUploading = true);

        File file = File(xFile.path);
        String fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}_${xFile.name}';
        
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

                    return UnifiedMessageBubble(
                      message: ChatMessage(
                        text: data['text'] ?? '',
                        imageUrl: data['imageUrl'] ?? '',
                        isMe: isMe,
                        time: timeStr,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading) const LinearProgressIndicator(color: Color(0xFFCD7F32)),
          UnifiedChatInputBar(
            controller: _messageController,
            isUploading: _isUploading,
            onSend: () => _sendMessage(text: _messageController.text.trim()),
            onPickImage: () => _pickAndUploadImage(fromCamera: false),
            onCaptureImage: () => _pickAndUploadImage(fromCamera: true),
            onCallTap: () {
              Navigator.pushNamed(context, '/call_screen');
            },
          ),
        ],
      ),
    );
  }
}

// Removed internal _MessageBubble and _MessageInputBar as they are now in chat_widgets.dart

