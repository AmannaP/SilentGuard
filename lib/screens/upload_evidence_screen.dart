import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/case_history.dart';
import '../services/archive_service.dart';
import '../utils/ui_utils.dart';

class UploadEvidenceScreen extends StatefulWidget {
  const UploadEvidenceScreen({super.key});

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  final CaseService _caseService = CaseService();
  final ArchiveService _archiveService = ArchiveService();
  bool _isUploading = false;

  Future<void> _pickAndUpload(String evidenceType, FileType type, {List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        setState(() {
          _isUploading = true;
        });

        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        String downloadUrl = await _caseService.uploadEvidence(file, fileName);

        if (downloadUrl.isNotEmpty) {
           await _archiveService.saveEvidence(fileName, evidenceType, downloadUrl);
        }

        if (mounted) {
          setState(() {
            _isUploading = false;
          });

          if (downloadUrl.isNotEmpty) {
            UIUtils.showCustomPopup(
              context,
              title: 'Upload Complete',
              message: 'Evidence securely attached to your vault!',
              isSuccess: true,
            );
          } else {
            UIUtils.showCustomPopup(
              context,
              title: 'Upload Invalid',
              message: 'Cloud storage returned an empty file path. The upload process was interrupted.',
              isSuccess: false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        UIUtils.showCustomPopup(
          context,
          title: 'Storage Error',
          message: e.toString(),
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload Evidence', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFCD7F32), // Bronze Theme
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
                Text('Uploading secure evidence...'),
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
                  'Please choose the type of evidence you would like to upload. Supported formats include text, video, and image files.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                _buildUploadCard(
                  context,
                  title: 'Image File',
                  icon: Icons.image_outlined,
                  color: const Color(0xFFCD7F32),
                  onTap: () => _pickAndUpload('image', FileType.image),
                ),
                const SizedBox(height: 16),
                _buildUploadCard(
                  context,
                  title: 'Video File',
                  icon: Icons.video_camera_back_outlined,
                  color: const Color(0xFFD4833B),
                  onTap: () => _pickAndUpload('video', FileType.video),
                ),
                const SizedBox(height: 16),
                _buildUploadCard(
                  context,
                  title: 'Text / Document',
                  icon: Icons.description_outlined,
                  color: const Color(0xFFA0522D),
                  onTap: () => _pickAndUpload('document', FileType.custom, allowedExtensions: ['pdf', 'doc', 'txt']),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildUploadCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(Icons.upload_file, color: color),
          ],
        ),
      ),
    );
  }
}
