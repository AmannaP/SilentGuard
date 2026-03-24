import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'call_screen.dart';
import 'case_screens.dart';

class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
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
                ],
              ),
            ),

            // --- Map Area ---
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _userPosition,
                      initialZoom: 14.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        ],
                      ),
                    ],
                  ),
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
                    ),
                  ),
                ],
              ),
            ),

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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        ),
      ),
    );
  }
}
