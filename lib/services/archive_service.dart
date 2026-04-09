import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArchiveEvidence {
  final String id;
  final String title;
  final String type;
  final String downloadUrl;
  final String timestamp;

  ArchiveEvidence({
    required this.id,
    required this.title,
    required this.type,
    required this.downloadUrl,
    required this.timestamp,
  });

  factory ArchiveEvidence.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    return ArchiveEvidence(
      id: doc.id,
      title: m['title'] ?? '',
      type: m['type'] ?? '',
      downloadUrl: m['downloadUrl'] ?? '',
      timestamp: m['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': type,
        'downloadUrl': downloadUrl,
        'timestamp': timestamp,
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'created_at': FieldValue.serverTimestamp(),
      };
}

class ArchiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _archive => _firestore.collection('archive_evidence');

  Stream<List<ArchiveEvidence>> getArchiveStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _archive
        .where('userId', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ArchiveEvidence.fromDoc(d)).toList());
  }

  Future<void> saveEvidence(String title, String type, String downloadUrl) async {
    final now = DateTime.now();
    final timeStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final evidence = ArchiveEvidence(
      id: '',
      title: title,
      type: type,
      downloadUrl: downloadUrl,
      timestamp: timeStr,
    );
    await _archive.add(evidence.toMap());
  }
}
