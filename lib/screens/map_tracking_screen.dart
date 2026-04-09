import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/tracking_service.dart';
import '../services/case_history.dart';
import 'call_screen.dart';
import 'case_screens.dart';

class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  final Color _themeOrange = const Color(0xFFD4793A);
  final TrackingService _trackingService = TrackingService();

  final MapController _mapController = MapController();
  final TextEditingController _userLocationController = TextEditingController(text: "Locating...");

  LatLng? userLatLng;
  LatLng? helperLatLng;
  String? requestId;
  String _etaText = "Waiting for help...";

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<DocumentSnapshot>? _requestSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (requestId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        requestId = args;
      } else {
        requestId = "demo_request_123";
      }
      _initTracking();
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _requestSubscription?.cancel();
    _userLocationController.dispose();
    super.dispose();
  }

  Future<void> _initTracking() async {
    // Start listening to user position
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          userLatLng = latLng;
          _userLocationController.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        });
      }

      if (requestId != null) {
        _trackingService.updateUserLocation(requestId!, position);
      }
      _moveCamera(latLng);
    });

    // Listen to helper updates via Service
    if (requestId != null) {
      _requestSubscription = _trackingService.getRequestStream(requestId!).listen((doc) {
        if (!doc.exists) return;

        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return;

        if (mounted) {
          setState(() {
            if (data['helper'] != null) {
              helperLatLng = LatLng(data['helper']['lat'], data['helper']['lng']);
              _etaText = data['eta'] ?? "Help is on the way";
            } else {
              _etaText = "Finding nearest help...";
            }
            
            if (data['status'] == 'resolved' || data['status'] == 'cancelled') {
              _showCompletionDialog(data['status']);
            }
          });
        }
      });
    }
  }

  void _showCompletionDialog(String status) {
    _positionStream?.cancel();
    _requestSubscription?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(status == 'resolved' ? "Help Arrived" : "Request Cancelled"),
        content: Text(status == 'resolved' 
          ? "The emergency request has been marked as resolved." 
          : "The emergency request was cancelled."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              Navigator.of(context).pop(); 
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel() async {
    if (requestId != null) {
      await _trackingService.cancelSOS(requestId!);
    }
    if (mounted) Navigator.pop(context);
  }

  void _moveCamera(LatLng position) {
    _mapController.move(position, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
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
                  _buildLocationBox(
                    Icons.directions_car, 
                    helperLatLng != null ? "Helper is moving" : "Finding Helper...", 
                    false
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: userLatLng ?? const LatLng(5.6037, -0.1870), 
                      initialZoom: 14.0,
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
                              width: 50,
                              height: 50,
                              child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                            ),
                          if (helperLatLng != null)
                            Marker(
                              point: helperLatLng!,
                              width: 50,
                              height: 50,
                              child: const Icon(Icons.directions_car, color: Colors.red, size: 40),
                            ),
                        ],
                      ),
                    ],
                  ),
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
                  Text(
                    _etaText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF5F5FA),
                      fontSize: 22,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: _handleCancel,
                      icon: const Icon(Icons.close, color: Colors.black, size: 20),
                      label: const Text(
                        "Cancel SOS",
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
              readOnly: true,
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
          Expanded(
            child: Text(
              text,
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
        final sosCase = CaseModel(
          incidentNumber: 'SOS-${requestId ?? '123'}',
          priorityLevel: 'High',
          date: 'Now',
          time: '',
          status: 'Emergency',
          officer: 'Dispatch',
          victimName: 'Current User',
          victimDob: '',
          victimGender: '',
          victimPhone: '',
          location: 'Current Location',
          incidentDate: 'Now',
          caseType: 'SOS Emergency',
          description: 'Live SOS Tracking Session',
          immediateNeeds: [],
          id: requestId ?? 'admin-tracking', // Fallback ID for chat
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => CaseChatScreen(caseModel: sosCase)));
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
              "Chat",
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
