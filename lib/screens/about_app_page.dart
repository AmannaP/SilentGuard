import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bronze = Color(0xFFCD7F32);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Silent Guard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: bronze,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: const BoxDecoration(
                color: bronze,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.shield_outlined, size: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Silent Guard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Safety, Our Priority',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mission Statement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bronze),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Silent Guard is dedicated to providing an immediate, secure, and intuitive platform for victims of Gender-Based Violence (GBV) in partnership with Renel Ghana. Our goal is to bridge the gap between emergency situations and professional intervention while ensuring complete data privacy and security.',
                    style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Key Features',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bronze),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureItem(
                    Icons.emergency,
                    'Instant SOS Alert',
                    'Active background location tracking and immediate response triggering for critical situations.',
                  ),
                  _buildFeatureItem(
                    Icons.inventory_2_outlined,
                    'Secure Evidence Vault',
                    'Upload images, videos, and voice recordings securely into an encrypted repository.',
                  ),
                  _buildFeatureItem(
                    Icons.history_edu_outlined,
                    'Case Transparency',
                    'Log and track your reports with real-time updates and direct communication with assigned officers.',
                  ),
                  _buildFeatureItem(
                    Icons.fingerprint,
                    'Advanced Privacy',
                    'Your data is encrypted and only accessible to authorized intervention staff.',
                  ),
                  
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Version 2.0.4 • © 2026 Silent Guard',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFCD7F32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFCD7F32), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
