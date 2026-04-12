import 'dart:io';
import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final String imageUrl;
  final bool isMe;
  final String time;
  final String? senderLabel;
  final String? caseTag;

  ChatMessage({
    required this.text,
    required this.imageUrl,
    required this.isMe,
    required this.time,
    this.senderLabel,
    this.caseTag,
  });
}

class UnifiedMessageBubble extends StatelessWidget {
  final ChatMessage message;
  static const Color _bronze = Color(0xFFCD7F32);

  const UnifiedMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool hasImage = message.imageUrl.isNotEmpty;
    bool hasText = message.text.isNotEmpty;

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isMe ? _bronze.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Case identification tag (for staff messages to remind the victim)
            if (!message.isMe && message.caseTag != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _bronze.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Case: ${message.caseTag}',
                  style: const TextStyle(
                    fontSize: 9, 
                    fontWeight: FontWeight.bold, 
                    color: _bronze
                  ),
                ),
              ),

            if (!message.isMe && message.senderLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderLabel!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _bronze,
                  ),
                ),
              ),

            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImage(message.imageUrl),
                ),
              ),

            if (hasText)
              Text(
                message.text,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
              ),
            
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 12, color: _bronze),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('local://')) {
      final path = url.replaceFirst('local://', '');
      return Image.file(
        File(path),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
      );
    }
    return Image.network(
      url,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 180,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.grey, size: 30),
          SizedBox(height: 8),
          Text('Image unavailable', style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}

class UnifiedChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback? onCaptureImage;
  final VoidCallback onCallTap;
  final bool isUploading;

  const UnifiedChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    this.onCaptureImage,
    required this.onCallTap,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isUploading) const LinearProgressIndicator(color: Color(0xFFCD7F32), height: 2),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFFCD7F32)),
                  onPressed: onPickImage,
                ),
                if (onCaptureImage != null)
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                    onPressed: onCaptureImage,
                  ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFCD7F32),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: onSend,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
