import 'package:flutter/material.dart';

class RealDashboard extends StatelessWidget {
  const RealDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SilentGuard SOS",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004D40),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {}, // Will lead to your Incident History
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Map Header / Location Display
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 10),
                const Text(
                  "Current Location: Accra, Ghana",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 2. The Main SOS Button (The Heart of the App)
          GestureDetector(
            onLongPress: () {
              // This is where you trigger the SOS logic!
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("SOS ALERT SENT TO RENEL GHANA")),
              );
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    spreadRadius: 10,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "SOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "HOLD BUTTON FOR 3 SECONDS",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),

          const Spacer(),

          // 3. Quick Action Cards (Evidence Capture)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(Icons.mic, "Record"),
                _buildActionCard(Icons.camera_alt, "Photo"),
                _buildActionCard(Icons.shield, "Safe-house"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF004D40),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
