import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/tracking_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _themeOrange = const Color(0xFFD4793A);
  final TrackingService _trackingService = TrackingService();
  String _currentAddress = "Locating...";
  Position? _currentPosition;
  bool _isTriggering = false;
  String? _activeRequestId;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _initLocation();
    _checkActiveSOS();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final doc = await AuthService().getUserData(user.uid);
      if (doc.exists && mounted) {
        setState(() {
          _userName = (doc.data() as Map<String, dynamic>)['fullName'] ?? 'User';
        });
      }
    }
  }

  Future<void> _checkActiveSOS() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('active_sos_id');
    if (mounted) {
      setState(() {
        _activeRequestId = savedId;
      });
    }
  }

  Future<void> _initLocation() async {
    debugPrint("--- Initializing Location ---");
    final position = await _trackingService.getCurrentLocation();
    if (mounted) {
      setState(() {
        if (position != null) {
          _currentPosition = position;
          _currentAddress = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          debugPrint("Location Found: $_currentAddress");
        } else {
          _currentAddress = "Location unavailable";
          debugPrint("Location could not be fetched.");
        }
      });
    }
  }

  Future<void> _triggerSOS() async {
    debugPrint("--- SOS Long Press Detected ---");
    
    if (_isTriggering) return;

    setState(() => _isTriggering = true);

    try {
      if (_currentPosition == null) {
        debugPrint("Position null, attempting to fetch...");
        _currentPosition = await _trackingService.getCurrentLocation();
      }

      if (_currentPosition == null) {
        debugPrint("Position still null after retry.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: GPS location not found. Please enable GPS.')),
          );
        }
        setState(() => _isTriggering = false);
        return;
      }

      debugPrint("Triggering SOS API in Firestore...");
      final requestId = await _trackingService.triggerSOS(
        _currentPosition!, 
        userName: _userName,
      );
      debugPrint("SOS Triggered! Request ID: $requestId");

      // Save to persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_sos_id', requestId);

      if (mounted) {
        setState(() => _activeRequestId = requestId);
        Navigator.pushNamed(
          context,
          '/map_tracking',
          arguments: requestId,
        ).then((_) => _checkActiveSOS()); // Re-check when coming back
      }
    } catch (e) {
      debugPrint("SOS Trigger Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to trigger SOS: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTriggering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  if (_activeRequestId != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/map_tracking',
                          arguments: _activeRequestId,
                        ).then((_) => _checkActiveSOS());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.bolt, color: _themeOrange, size: 28),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current location",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _currentAddress,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, size: 28),
                    onPressed: () => Navigator.pushNamed(context, '/record_evidence_screen'),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, size: 28),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No new notifications')),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Are you in an\nemergency?",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Press the SOS button, your live location will be shared with the nearest help centre and your emergency contacts",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.person_outline, size: 80),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // --- SOS Button ---
                    Center(
                      child: GestureDetector(
                        onLongPress: _triggerSOS,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Press and hold the SOS button to activate'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          padding: const EdgeInsets.all(25),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isTriggering 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "SOS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Hold to activate",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildActionItem(
                      Icons.chat,
                      "Message Someone",
                      Colors.orange.shade100,
                      onTap: () => Navigator.pushNamed(context, '/contacts_screen'),
                    ),
                    _buildActionItem(
                      Icons.medical_services,
                      "Upload Evidence",
                      Colors.green.shade100,
                      onTap: () => Navigator.pushNamed(context, '/upload_evidence_screen'),
                    ),
                    _buildActionItem(
                      Icons.phone_in_talk,
                      "Place a call",
                      Colors.blue.shade100,
                      onTap: () => Navigator.pushNamed(context, '/call_screen'),
                    ),
                    _buildActionItem(
                      Icons.mic,
                      "Record Evidence",
                      Colors.purple.shade100,
                      onTap: () => Navigator.pushNamed(context, '/record_evidence_screen'),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color iconBg, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
