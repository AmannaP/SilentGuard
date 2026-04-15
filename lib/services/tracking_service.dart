import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';

class TrackingService {
  // Use a getter so it only accesses Firestore when needed
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getRequestStream(String requestId) {
    return _firestore.collection('tracking').doc(requestId).snapshots();
  }

  Future<String> triggerSOS(Position position, {String? userName, String? emergencyName, String? emergencyPhone}) async {
    final authService = AuthService();
    final uid = authService.currentUser?.uid ?? 'unknown';

    DocumentReference docRef = await _firestore.collection('tracking').add({
      'user': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
      'userName': userName ?? 'Anonymous User',
      'emergencyContact': {
        'name': emergencyName ?? 'None',
        'phone': emergencyPhone ?? 'None',
      },
      'status': 'emergency',
      'timestamp': FieldValue.serverTimestamp(),
      'displayDate': DateTime.now().toString().substring(0, 16), // "2024-04-12 12:05"
      'userId': uid,
    });
    return docRef.id;
  }

  /// Finds an active SOS request for the user in Firestore.
  /// Returns the document ID if found, otherwise null.
  Future<String?> getActiveSOS(String uid) async {
    final query = await _firestore
        .collection('tracking')
        .where('userId', isEqualTo: uid)
        .where('status', whereIn: ['emergency', 'help_on_the_way'])
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  Future<void> updateUserLocation(String requestId, Position position) async {
    await _firestore.collection('tracking').doc(requestId).update({
      'user': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelSOS(String requestId) async {
    await _firestore.collection('tracking').doc(requestId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
