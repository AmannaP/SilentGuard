import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class TrackingService {
  // Use a getter so it only accesses Firestore when needed
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getRequestStream(String requestId) {
    return _firestore.collection('tracking').doc(requestId).snapshots();
  }

  Future<String> triggerSOS(Position position) async {
    DocumentReference docRef = await _firestore.collection('tracking').add({
      'user': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
      'status': 'emergency',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': 'demo_user',
    });
    return docRef.id;
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
