import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/case_history.dart';
import '../services/archive_service.dart';

class RecordEvidenceScreen extends StatefulWidget {
  const RecordEvidenceScreen({super.key});

  @override
  State<RecordEvidenceScreen> createState() => _RecordEvidenceScreenState();
}

class _RecordEvidenceScreenState extends State<RecordEvidenceScreen> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isUploading = false;
  final CaseService _caseService = CaseService();
  final ArchiveService _archiveService = ArchiveService();

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/evidence_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        if (mounted) {
          setState(() {
            _isRecording = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        
        if (path != null) {
          setState(() => _isUploading = true);

          try {
            File file = File(path);
            String fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

            String downloadUrl = await _caseService.uploadEvidence(file, fileName);
            
            if (downloadUrl.isNotEmpty) {
              await _archiveService.saveEvidence(fileName, 'audio', downloadUrl);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio recorded successfully and saved to vault!')),
                );
                Navigator.pop(context, path);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification Failed: Could not acquire URL')),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload Error: $e')),
              );
            }
          } finally {
            if (mounted) setState(() => _isUploading = false);
          }
        }
      }
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  Future<void> _recordVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
         setState(() => _isUploading = true);
         try {
            File file = File(video.path);
            String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

            String downloadUrl = await _caseService.uploadEvidence(file, fileName);
            
            if (downloadUrl.isNotEmpty) {
              await _archiveService.saveEvidence(fileName, 'video', downloadUrl);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video recorded securely and saved to vault!')),
                );
                Navigator.pop(context, video.path);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification Failed: Could not acquire URL')),
                );
              }
            }
         } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload Error: $e')),
              );
            }
         } finally {
            if (mounted) setState(() => _isUploading = false);
         }
      }
    } catch (e) {
      debugPrint("Error recording video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Record Evidence', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFCD7F32), // Bronze Theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : const Color(0xFFCD7F32).withOpacity(0.1),
                  border: Border.all(color: _isRecording ? Colors.red : const Color(0xFFCD7F32).withOpacity(0.3), width: 4),
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 80,
                  color: _isRecording ? Colors.white : const Color(0xFFCD7F32),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isRecording ? 'Recording... Tap to stop' : 'Tap to start recording',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'Audio will be securely saved into your vault automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            if (_isUploading) const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32))),
            if (_isUploading) const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _recordVideo,
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Switch to Video Recording', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCD7F32),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
