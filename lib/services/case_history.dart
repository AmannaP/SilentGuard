import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class CaseUpdate {
  final String date;
  final String message;
  final String author;

  const CaseUpdate({
    required this.date,
    required this.message,
    required this.author,
  });

  factory CaseUpdate.fromMap(Map<String, dynamic> m) => CaseUpdate(
        date: m['date'] ?? '',
        message: m['message'] ?? '',
        author: m['author'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'date': date,
        'message': message,
        'author': author,
      };
}

class CaseMedia {
  final String type; 
  final String label;
  final String size;
  final String path;

  const CaseMedia({
    required this.type,
    required this.label,
    required this.size,
    this.path = '',
  });

  factory CaseMedia.fromMap(Map<String, dynamic> m) => CaseMedia(
        type: m['type'] ?? '',
        label: m['label'] ?? '',
        size: m['size'] ?? '',
        path: m['path'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'label': label,
        'size': size,
        'path': path,
      };
}

class CaseModel {
  final String? id;
  // System-assigned
  final String incidentNumber;
  final String priorityLevel;
  final String date;
  final String time;
  String status;
  final String officer;

  // Client info
  final String victimName;
  final String victimDob;
  final String victimGender;
  final String victimPhone;
  final String location;

  // Incident detail
  final String incidentDate;
  final String caseType;
  final String description;
  final List<String> immediateNeeds;

  final List<CaseUpdate> updates;
  final List<CaseMedia> media;
  final String? userId; // Owner of the case

  CaseModel({
    this.id,
    required this.incidentNumber,
    required this.priorityLevel,
    required this.date,
    required this.time,
    required this.status,
    required this.officer,
    required this.victimName,
    required this.victimDob,
    required this.victimGender,
    required this.victimPhone,
    required this.location,
    required this.incidentDate,
    required this.caseType,
    required this.description,
    required this.immediateNeeds,
    this.updates = const [],
    this.media = const [],
    this.userId,
  });

  factory CaseModel.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return CaseModel(
      id: doc.id,
      incidentNumber: m['incident_number'] ?? '',
      priorityLevel: m['priority_level'] ?? 'Medium',
      date: m['date'] ?? '',
      time: m['time'] ?? '',
      status: m['status'] ?? '',
      officer: m['officer'] ?? '',
      victimName: m['victim_name'] ?? '',
      victimDob: m['victim_dob'] ?? '',
      victimGender: m['victim_gender'] ?? '',
      victimPhone: m['victim_phone'] ?? '',
      location: m['location'] ?? '',
      incidentDate: m['incident_date'] ?? '',
      caseType: m['case_type'] ?? '',
      description: m['description'] ?? '',
      immediateNeeds: List<String>.from(m['immediate_needs'] ?? []),
      updates: (m['updates'] as List<dynamic>? ?? [])
          .map((u) => CaseUpdate.fromMap(Map<String, dynamic>.from(u)))
          .toList(),
      media: (m['media'] as List<dynamic>? ?? [])
          .map((x) => CaseMedia.fromMap(Map<String, dynamic>.from(x)))
          .toList(),
      userId: m['userId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'incident_number': incidentNumber,
        'priority_level': priorityLevel,
        'date': date,
        'time': time,
        'status': status,
        'officer': officer,
        'victim_name': victimName,
        'victim_dob': victimDob,
        'victim_gender': victimGender,
        'victim_phone': victimPhone,
        'location': location,
        'incident_date': incidentDate,
        'case_type': caseType,
        'description': description,
        'immediate_needs': immediateNeeds,
        'updates': updates.map((u) => u.toMap()).toList(),
        'media': media.map((x) => x.toMap()).toList(),
        'userId': userId,
        'created_at': FieldValue.serverTimestamp(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// CASE SERVICE (Firebase)
// ─────────────────────────────────────────────────────────────────────────────

class CaseService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference get _cases => _firestore.collection('cases');

  Stream<List<CaseModel>> getCasesStream({String? userId}) {
    Query query = _cases;
    
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    
    return query.snapshots().map((snap) {
      // Convert to a mutable list of document snapshots
      final docs = snap.docs.toList();
      
      // Sort in-memory instead of using Firestore's orderBy to avoid indexing requirements
      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final Timestamp? tsA = dataA['created_at'] as Timestamp?;
        final Timestamp? tsB = dataB['created_at'] as Timestamp?;
        
        // Handle potential null timestamps (for documents being written)
        if (tsA == null) return -1; 
        if (tsB == null) return 1;
        
        return tsB.compareTo(tsA); // Sort descending (most recent first)
      });

      return docs.map((d) => CaseModel.fromDoc(d)).toList();
    });
  }

  Future<String> createCase(CaseModel newCase) async {
    final docRef = await _cases.add(newCase.toMap());
    return docRef.id;
  }

  Future<String> uploadEvidence(File file, String fileName) async {
    try {
      // 1. Ensure a user is logged in — Storage rules often require auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated. Please log in and try again.');
      
      // 2. Force-refresh the auth token so it's not stale
      await user.getIdToken(true);
      
      // 3. Sanitize the file name (remove special chars that break Cloud Storage paths)
      final String ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
      final String cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9\\._-]'), '_');
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$cleanName';
      
      // 4. Determine content type for proper Storage indexing
      final Map<String, String> contentTypeMap = {
        'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
        'gif': 'image/gif', 'webp': 'image/webp',
        'mp4': 'video/mp4', 'mov': 'video/quicktime', 'avi': 'video/x-msvideo',
        'mp3': 'audio/mpeg', 'wav': 'audio/wav', 'm4a': 'audio/mp4',
        'pdf': 'application/pdf', 'doc': 'application/msword',
        'txt': 'text/plain', 'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      };
      final String? contentType = contentTypeMap[ext];
      
      debugPrint('Starting upload: $uniqueFileName (type: ${contentType ?? 'auto'})');

      final ref = FirebaseStorage.instance
          .ref()
          .child('cases_evidence')
          .child(user.uid) // Store per-user for easier Storage rules scoping
          .child(uniqueFileName);
      
      // 5. Use SettableMetadata to ensure proper content-type is set on the object
      final metadata = contentType != null 
          ? SettableMetadata(contentType: contentType)
          : null;

      // 6. Upload using putFile (more reliable than putData for file paths on Android)
      final UploadTask uploadTask = metadata != null 
          ? ref.putFile(file, metadata) 
          : ref.putFile(file);
      
      final TaskSnapshot snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        debugPrint('Upload success. Getting download URL...');
        final url = await snapshot.ref.getDownloadURL();
        debugPrint('Got URL: $url');
        return url;
      } else {
        throw Exception('Upload did not complete. State: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error [${e.code}]: ${e.message}');
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        throw Exception('Permission denied. Check Firebase Storage security rules.');
      } else if (e.code == 'object-not-found') {
        debugPrint('File uploaded but URL not found. Falling back to local file URI.');
        return 'local://${file.path}';
      } else if (e.code == 'canceled') {
        throw Exception('Upload was cancelled.');
      }
      rethrow;
    } catch (e) {
      debugPrint('General Upload Error: $e');
      rethrow;
    }
  }
}
