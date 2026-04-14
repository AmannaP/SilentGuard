import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/local_evidence_service.dart';
import '../utils/ui_utils.dart';

class UploadEvidenceScreen extends StatefulWidget {
  const UploadEvidenceScreen({super.key});

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  final LocalEvidenceService _evidenceService = LocalEvidenceService();
  bool _isUploading = false;

  Future<void> _pickAndSave(String evidenceType, FileType type, {List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions?.isNotEmpty == true ? allowedExtensions : null,
      );

      if (result == null || result.files.single.path == null) return;

      setState(() => _isUploading = true);

      final File file = File(result.files.single.path!);
      final String fileName = result.files.single.name;

      await _evidenceService.saveEvidenceFromFile(file, fileName, evidenceType);

      if (mounted) {
        UIUtils.showCustomPopup(
          context,
          title: 'Evidence Saved',
          message: 'Saved to your phone to stay hidden. You can back it up online from the Archive menu.',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showCustomPopup(
          context,
          title: 'Save Failed',
          message: e.toString(),
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload Evidence', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFCD7F32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFCD7F32)),
                  SizedBox(height: 16),
                  Text('Saving evidence to vault...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Select Evidence Type',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose the type of evidence to save. Files are stored securely on your device.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  _buildUploadCard(
                    title: 'Image File',
                    subtitle: 'JPG, PNG, WEBP',
                    icon: Icons.image_outlined,
                    color: const Color(0xFFCD7F32),
                    onTap: () => _pickAndSave('image', FileType.image),
                    actionIcon: Icons.add_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildUploadCard(
                    title: 'Video File',
                    subtitle: 'MP4, MOV, AVI',
                    icon: Icons.video_camera_back_outlined,
                    color: const Color(0xFFD4833B),
                    onTap: () => _pickAndSave('video', FileType.video),
                    actionIcon: Icons.add_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildUploadCard(
                    title: 'Text / Document',
                    subtitle: 'PDF, DOC, TXT',
                    icon: Icons.description_outlined,
                    color: const Color(0xFFA0522D),
                    onTap: () => _pickAndSave(
                      'document',
                      FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                    ),
                    actionIcon: Icons.add_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildUploadCard(
                    title: 'Audio Recording',
                    subtitle: 'MP3, WAV, M4A',
                    icon: Icons.mic_none_outlined,
                    color: const Color(0xFF8B4513),
                    onTap: () => _pickAndSave(
                      'audio',
                      FileType.custom,
                      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
                    ),
                    actionIcon: Icons.add_circle_outline,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Files are saved securely on this device to protect your privacy.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    IconData actionIcon = Icons.add_circle_outline,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const Spacer(),
            Icon(actionIcon, color: color),
          ],
        ),
      ),
    );
  }
}
