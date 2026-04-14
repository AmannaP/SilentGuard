import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LOCAL EVIDENCE MODEL
// ─────────────────────────────────────────────────────────────────────────────

class LocalEvidence {
  final String id;
  final String title;
  final String type; // image, video, audio, document
  final String localPath; // path on device
  final String timestamp;
  final String userId;

  const LocalEvidence({
    required this.id,
    required this.title,
    required this.type,
    required this.localPath,
    required this.timestamp,
    required this.userId,
  });

  factory LocalEvidence.fromJson(Map<String, dynamic> json) => LocalEvidence(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        localPath: json['localPath'] ?? '',
        timestamp: json['timestamp'] ?? '',
        userId: json['userId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'localPath': localPath,
        'timestamp': timestamp,
        'userId': userId,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCAL EVIDENCE SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class LocalEvidenceService {
  static const String _prefsKey = 'local_evidence_list';

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  // Copy a picked file into the app's permanent documents directory
  Future<String> saveFileLocally(File sourceFile, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory('${dir.path}/evidence/$_currentUserId');
      await evidenceDir.create(recursive: true);

      // Sanitize file name
      final clean = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final unique = '${DateTime.now().millisecondsSinceEpoch}_$clean';
      final destPath = '${evidenceDir.path}/$unique';

      await sourceFile.copy(destPath);
      debugPrint('File saved locally: $destPath');
      return destPath;
    } catch (e) {
      debugPrint('LocalEvidenceService.saveFileLocally error: $e');
      rethrow;
    }
  }

  // Save metadata to SharedPreferences
  Future<void> addEvidence(LocalEvidence evidence) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey);
    final List<dynamic> list = existing != null ? jsonDecode(existing) : [];
    list.insert(0, evidence.toJson()); // newest first
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  // Get all evidence for current user
  Future<List<LocalEvidence>> getMyEvidence() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey);
    if (existing == null) return [];

    final List<dynamic> list = jsonDecode(existing);
    return list
        .map((e) => LocalEvidence.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.userId == _currentUserId)
        .toList();
  }

  // Delete a specific evidence entry and its file
  Future<void> deleteEvidence(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey);
    if (existing == null) return;

    final List<dynamic> list = jsonDecode(existing);
    final items = list
        .map((e) => LocalEvidence.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final toDelete = items.firstWhere((e) => e.id == id, orElse: () => const LocalEvidence(id: '', title: '', type: '', localPath: '', timestamp: '', userId: ''));
    if (toDelete.id.isNotEmpty) {
      final file = File(toDelete.localPath);
      if (await file.exists()) await file.delete();
    }

    items.removeWhere((e) => e.id == id);
    await prefs.setString(_prefsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Helper: create and save a full LocalEvidence from a file
  Future<LocalEvidence> saveEvidenceFromFile(File file, String originalName, String type) async {
    final localPath = await saveFileLocally(file, originalName);
    final now = DateTime.now();
    final timeStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final id = '${_currentUserId}_${now.millisecondsSinceEpoch}';

    final evidence = LocalEvidence(
      id: id,
      title: originalName,
      type: type,
      localPath: localPath,
      timestamp: timeStr,
      userId: _currentUserId,
    );

    await addEvidence(evidence);
    return evidence;
  }
}
