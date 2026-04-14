import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackStatus { open, inProgress, resolved }

class FeedbackModel {
  final String? id;
  final String userId;
  final String userName;
  final String userEmail;
  final String message;
  final String type; // Bug, Feature Request, General Support
  final DateTime timestamp;
  FeedbackStatus status;
  String? adminReply;

  FeedbackModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.message,
    required this.type,
    required this.timestamp,
    this.status = FeedbackStatus.open,
    this.adminReply,
  });

  factory FeedbackModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userEmail: data['userEmail'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'Support',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'open'),
        orElse: () => FeedbackStatus.open,
      ),
      adminReply: data['adminReply'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status.name,
      'adminReply': adminReply,
    };
  }
}

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _feedbacks => _firestore.collection('feedbacks');

  // Submit feedback (User)
  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _feedbacks.add(feedback.toMap());
  }

  // Get all feedbacks (Admin)
  Stream<List<FeedbackModel>> getFeedbacksStream() {
    return _feedbacks
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FeedbackModel.fromDoc(doc)).toList());
  }

  // Get user-specific feedbacks (Victim)
  Stream<List<FeedbackModel>> getMyFeedbacksStream(String userId) {
    return _feedbacks
        .where('userId', isEqualTo: userId)
        .snapshots() // We do in-memory sorting later to avoid composite index requirements
        .map((snap) {
          final list = snap.docs.map((doc) => FeedbackModel.fromDoc(doc)).toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  // Update feedback status/reply (Admin)
  Future<void> updateFeedback(String id, {FeedbackStatus? status, String? adminReply}) async {
    final Map<String, dynamic> updates = {};
    if (status != null) updates['status'] = status.name;
    if (adminReply != null) updates['adminReply'] = adminReply;
    
    await _feedbacks.doc(id).update(updates);
  }
}
