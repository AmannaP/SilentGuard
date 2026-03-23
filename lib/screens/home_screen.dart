import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color _themeOrange = const Color(0xFFD4793A);

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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bolt, color: _themeOrange, size: 28),
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
                          children: const [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.black,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Accra, Ghana",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.camera_alt_outlined, size: 28),
                  const SizedBox(width: 15),
                  const Icon(Icons.notifications_none_outlined, size: 28),
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
                    // --- Emergency Section ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
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
                        // Illustration Placeholder
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
                        onLongPress: () => Navigator.pushNamed(
                          context,
                          '/map_tracking_screen',
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Press and hold for 3 seconds to activate SOS'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "SOS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Hold for 3\nseconds",
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

                    const SizedBox(height: 40),

                    // --- Quick Actions ---
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
                      const SizedBox(height: 100), // Space for Bottom Nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      // Custom Bottom Navigation
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
