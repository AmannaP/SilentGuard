import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/archive_service.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Match modern theme slightly off-white
      appBar: AppBar(
        title: const Text('Evidence Archive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFCD7F32), // Bronze Theme
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<ArchiveEvidence>>(
        stream: ArchiveService().getArchiveStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No archived evidence yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final evidence = items[index];
              IconData iconData = Icons.insert_drive_file;
              if (evidence.type == 'image') iconData = Icons.image;
              if (evidence.type == 'video') iconData = Icons.video_camera_back;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFCD7F32).withOpacity(0.1),
                    child: Icon(iconData, color: const Color(0xFFCD7F32)),
                  ),
                  title: Text(evidence.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Uploaded: ${evidence.timestamp}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_rounded, color: Color(0xFFCD7F32)),
                    onPressed: () => _launchUrl(evidence.downloadUrl),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
