import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  // Attached files/history
  final List<CaseUpdate> updates;
  final List<CaseMedia> media;

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
        'created_at': FieldValue.serverTimestamp(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// CASE SERVICE (Firebase)
// ─────────────────────────────────────────────────────────────────────────────

class CaseService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference get _cases => _firestore.collection('cases');

  Stream<List<CaseModel>> getCasesStream() {
    return _cases
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CaseModel.fromDoc(d)).toList());
  }

  Future<String> createCase(CaseModel newCase) async {
    final docRef = await _cases.add(newCase.toMap());
    return docRef.id;
  }

  Future<String> uploadEvidence(File file, String fileName) async {
    try {
      // Sanitize file name to fix 'object-not-found' issues on some devices
      final String cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$cleanName';
      
      final ref = FirebaseStorage.instance.ref().child('cases_evidence').child(uniqueFileName);
      
      // We use putData as it is more reliable across some Android devices when path access is restricted
      final snapshot = await ref.putData(await file.readAsBytes());
      
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception("Upload failed: TaskState is ${snapshot.state}");
      }
    } catch (e) {
      // Fallback equivalent to case upload form: use local path when cloud bucket is unavailable.
      return 'local://${file.path}';
    }
  }
}
