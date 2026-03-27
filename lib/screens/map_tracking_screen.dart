import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  final Color _themeOrange = const Color(0xFFD4793A);

  final MapController _mapController = MapController();

  LatLng? userLatLng;
  LatLng? helperLatLng;

  final String requestId = "demo_request_123";

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // ===============================
  //  INIT TRACKING
  // ===============================
  Future<void> _initTracking() async {
    // Request permission
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // USER LOCATION STREAM
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          userLatLng = latLng;
        });
      }

      _updateUserLocation(position.latitude, position.longitude);

      _moveCamera(latLng);
    });

    // HELPER LISTENER (Firebase)
    FirebaseFirestore.instance
        .collection('tracking')
        .doc(requestId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null || data['helper'] == null) return;

      final helper = data['helper'];

      if (mounted) {
        setState(() {
          helperLatLng = LatLng(helper['lat'], helper['lng']);
        });
      }
    });
  }

  // ===============================
  // 📡 FIREBASE UPDATE
  // ===============================
  Future<void> _updateUserLocation(double lat, double lng) async {
    try {
      await FirebaseFirestore.instance
          .collection('tracking')
          .doc(requestId)
          .set({
        'user': {
          'lat': lat,
          'lng': lng,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  // ===============================
  // 🎥 CAMERA CONTROL
  // ===============================
  void _moveCamera(LatLng position) {
    _mapController.move(position, 14.0);
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
            // ===============================
            //  LOCATION BOX
            // ===============================
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _themeOrange,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black),
                      const SizedBox(height: 5),
                      Column(
                        children: List.generate(
                          4,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Icon(Icons.directions_car, color: Colors.black),
                    ],
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      children: [
                        _buildLocationField("Your location"),
                        const SizedBox(height: 10),
                        _buildLocationField("Helper's location"),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // ===============================
            // MAP (using flutter_map)
            // ===============================
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(6.5244, 3.3792),
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.silent_guard',
                      ),
                      MarkerLayer(
                        markers: [
                          if (userLatLng != null)
                            Marker(
                              point: userLatLng!,
                              width: 80,
                              height: 80,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          if (helperLatLng != null)
                            Marker(
                              point: helperLatLng!,
                              width: 80,
                              height: 80,
                              child: const Icon(Icons.directions_car, color: Colors.blue, size: 40),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // 📞 CALL BUTTON
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 5)
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.phone, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Call",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===============================
            // BOTTOM SECTION
            // ===============================
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // ETA BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                color: Colors.white, size: 32),
                            SizedBox(width: 15),
                            Text(
                              "Help is 10 mins away",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.white54),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // CANCEL BUTTON
                  SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "✕ Cancel",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===============================
  // REUSABLE FIELD
  // ===============================
  Widget _buildLocationField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
