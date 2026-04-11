import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verified Contacts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFCD7F32), // Bronze Theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildContactTile(
            context,
            name: "Renel Ghana",
            role: "Service Provider / Admin Default",
            phone: "+233 55 123 4567",
            uid: "renel_ghana_default",
          ),
          // System can fetch from Firebase 'service_providers' later
        ],
      )
    );
  }

  Widget _buildContactTile(BuildContext context, {required String name, required String role, required String phone, required String uid}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xFFCD7F32),
        child: Icon(Icons.shield, color: Colors.white, size: 30),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
      subtitle: Text(role, style: const TextStyle(color: Colors.black54)),
      trailing: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.chat, color: Colors.green),
          onPressed: () {
             Navigator.pushNamed(
                context, 
                '/chat_provider',
                arguments: {
                  'uid': uid,
                  'name': name,
                  'phone': phone,
                }
              );
          },
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/chat_provider',
          arguments: {
            'uid': uid,
            'name': name,
            'phone': phone,
          }
        );
      },
    );
  }
}
