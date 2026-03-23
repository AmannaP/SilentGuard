import 'package:flutter/material.dart';

class MapTrackingScreen extends StatelessWidget {
  const MapTrackingScreen({super.key});

  final Color _themeOrange = const Color(0xFFD4793A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Location Selection ---
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildLocationBox(Icons.location_on_outlined, "Your location"),
                  const SizedBox(height: 10),
                  _buildLocationBox(Icons.directions_car_filled_outlined, "Helper's location"),
                ],
              ),
            ),

            // --- Map Area (Mock) ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://miro.medium.com/v2/resize:fit:1400/1*q69p7RndXf0S349_y9N55g.png'), // Placeholder Map Image
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ),
            ),

            // --- Bottom Info Section ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: _themeOrange,
              ),
              child: Column(
                children: [
                  // Call Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.phone, size: 20),
                          SizedBox(width: 8),
                          Text("Call", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ETA Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.directions_car, color: Colors.white, size: 32),
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
                  ),

                  const SizedBox(height: 30),

                  // Cancel Button
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black),
                      label: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
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

  Widget _buildLocationBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
