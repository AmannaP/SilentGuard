import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/local_evidence_service.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final LocalEvidenceService _service = LocalEvidenceService();
  List<LocalEvidence> _items = [];
  bool _isLoading = true;

  static const Color _bronze = Color(0xFFCD7F32);

  @override
  void initState() {
    super.initState();
    _loadEvidence();
  }

  Future<void> _loadEvidence() async {
    setState(() => _isLoading = true);
    final items = await _service.getMyEvidence();
    if (mounted) setState(() { _items = items; _isLoading = false; });
  }

  Future<void> _openFile(LocalEvidence evidence) async {
    final file = File(evidence.localPath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File no longer exists on this device.')),
        );
      }
      return;
    }
    final result = await OpenFilex.open(evidence.localPath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }

  Future<void> _deleteEvidence(LocalEvidence evidence) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Evidence'),
        content: Text('Permanently delete "${evidence.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deleteEvidence(evidence.id);
      _loadEvidence();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Evidence Archive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _bronze,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadEvidence,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _bronze))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No archived evidence yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Upload evidence using the Archive tab', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _buildEvidenceCard(item);
                  },
                ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEvidenceCard(LocalEvidence evidence) {
    IconData iconData;
    Color iconColor;

    switch (evidence.type) {
      case 'image':
        iconData = Icons.image_outlined;
        iconColor = Colors.blue;
        break;
      case 'video':
        iconData = Icons.video_camera_back_outlined;
        iconColor = Colors.purple;
        break;
      case 'audio':
        iconData = Icons.mic_outlined;
        iconColor = Colors.green;
        break;
      case 'document':
        iconData = Icons.description_outlined;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file_outlined;
        iconColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Text(
          evidence.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${evidence.type.toUpperCase()} • Saved: ${evidence.timestamp}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, color: _bronze),
              tooltip: 'Open file',
              onPressed: () => _openFile(evidence),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              tooltip: 'Delete',
              onPressed: () => _deleteEvidence(evidence),
            ),
          ],
        ),
      ),
    );
  }
}
