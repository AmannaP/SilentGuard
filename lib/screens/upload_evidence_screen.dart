import 'package:flutter/material.dart';

class UploadEvidenceScreen extends StatelessWidget {
  const UploadEvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload Evidence', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
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
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildUploadCard(
              context,
              title: 'Video File',
              icon: Icons.video_camera_back_outlined,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildUploadCard(
              context,
              title: 'Text / Document',
              icon: Icons.description_outlined,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context, {required String title, required IconData icon, required Color color}) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title picker would open here.')),
        );
      },
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
