import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecordEvidenceScreen extends StatefulWidget {
  const RecordEvidenceScreen({super.key});

  @override
  State<RecordEvidenceScreen> createState() => _RecordEvidenceScreenState();
}

class _RecordEvidenceScreenState extends State<RecordEvidenceScreen> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _recordedFilePath;

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
            _recordedFilePath = path;
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
          _recordedFilePath = path;
        });
        
        if (path != null) {
          // Show success message and navigate back or offer playback/upload
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio recorded successfully and saved to vault!')),
          );
          // Return the file path to the previous screen if needed
          Navigator.pop(context, path);
        }
      }
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Record Evidence', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                  color: _isRecording ? Colors.red : Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.withOpacity(0.3), width: 4),
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 80,
                  color: _isRecording ? Colors.white : Colors.red,
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
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video recording not implemented yet!')),
                  );
                },
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Switch to Video Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
