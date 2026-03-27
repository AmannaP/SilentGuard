<<<<<<< HEAD
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
=======
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'call_screen.dart';
import 'case_screens.dart';
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef

class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
<<<<<<< HEAD
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
=======
  final Color _themeOrange = const Color(0xFFCD7F32);
  final TextEditingController _userLocationController = TextEditingController(text: "Locating...");
  
  LatLng _userPosition = const LatLng(5.6037, -0.1870); // Placeholder Accra
  final LatLng _helperPosition = const LatLng(5.6150, -0.1900); // Nearby helper
  
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initBackgroundGeolocation();
  }

  void _initBackgroundGeolocation() async {
    // Listen to location events
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      if (mounted) {
        setState(() {
          _userPosition = LatLng(location.coords.latitude, location.coords.longitude);
          _userLocationController.text = "${location.coords.latitude.toStringAsFixed(4)}, ${location.coords.longitude.toStringAsFixed(4)}";
          _mapController.move(_userPosition, 15.0);
        });
      }
    });

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      debugPrint('[onProviderChange] - $event');
    });

    // Configure Background Geolocation
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE
    ));
    
    bg.BackgroundGeolocation.start();
  }

>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
<<<<<<< HEAD
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
=======
            // --- Top Location Selection ---
             Container(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _themeOrange,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10), 
                ),
              ),
              child: Column(
                children: [
                  _buildEditableLocationBox(Icons.location_on, "Your location", _userLocationController),
                  const SizedBox(height: 15),
                  _buildLocationBox(Icons.directions_car, "Helper's location (Tracking...)", false),
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
                ],
              ),
            ),

<<<<<<< HEAD
            // ===============================
            // MAP (using flutter_map)
            // ===============================
=======
            // --- Map Area ---
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
<<<<<<< HEAD
                      initialCenter: const LatLng(6.5244, 3.3792),
                      initialZoom: 14,
=======
                      initialCenter: _userPosition,
                      initialZoom: 14.0,
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
<<<<<<< HEAD
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
=======
                        userAgentPackageName: 'com.example.silentguard',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _userPosition,
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                          ),
                          Marker(
                            point: _helperPosition,
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.directions_car, color: Colors.red, size: 40),
                          ),
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
                        ],
                      ),
                    ],
                  ),
<<<<<<< HEAD

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
=======
                  // Floating action buttons on map
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMessageButton(context),
                        const SizedBox(width: 10),
                        _buildCallButton(context),
                      ],
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
                    ),
                  ),
                ],
              ),
            ),

<<<<<<< HEAD
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
=======
            // --- Bottom Info Section ---
            Container(
              margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: _themeOrange,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                   // ETA
                  const Text(
                    "Help is 10 mins away",
                    style: TextStyle(
                      color: Color(0xFFF5F5FA),
                      fontSize: 24,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white),
                  const SizedBox(height: 15),

                  // Cancel Button
                  SizedBox(
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black, size: 20),
                      label: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black, 
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0C20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
                        ),
                      ),
                    ),
                  ),
                ],
              ),
<<<<<<< HEAD
            )
=======
            ),
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildEditableLocationBox(IconData icon, String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(
                color: Color(0xFF18191C),
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBox(IconData icon, String text, bool isShadow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: !isShadow ? Border.all(color: _themeOrange, width: 1) : null,
        boxShadow: isShadow ? const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ] : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF18191C),
              fontSize: 14,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CallScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFD4CDF9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, size: 16, color: Color(0xFF313A51)),
            ),
            const SizedBox(width: 10),
            const Text(
              "Call",
              style: TextStyle(
                color: Color(0xFF313A51),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CaseDetailsPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFD4CDF9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble, size: 16, color: Color(0xFF313A51)),
            ),
            const SizedBox(width: 10),
            const Text(
              "Message",
              style: TextStyle(
                color: Color(0xFF313A51),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
        ),
      ),
    );
  }
}
