import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _themeOrange = const Color(0xFFD4833B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for the body
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: Column(
        children: [
          // --- HEADER SECTION ---
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(color: _themeOrange),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(
                    'assets/profile_image.png',
                  ), // Replace with your image
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Itunuoluwa Abidoye",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "@Itunuoluwa",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                ),
              ],
            ),
          ),

          // --- MENU LIST SECTION ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMenuContainer([
                  _buildMenuItem(
                    Icons.person_outline,
                    "My Account",
                    sub: "Make changes to your account",
                    trailing: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  _buildMenuItem(
                    Icons.people_outline,
                    "Emergency Contact",
                    sub: "Manage your saved numbers",
                  ),
                  _buildMenuItem(
                    Icons.lock_outline,
                    "Face ID / Touch ID",
                    sub: "Manage your device security",
                    trailing: Switch(value: false, onChanged: (val) {}),
                  ),
                  _buildMenuItem(
                    Icons.verified_user_outlined,
                    "Two-Factor Authentication",
                    sub: "Further secure your account for safety",
                  ),
                  _buildMenuItem(
                    Icons.logout,
                    "Log out",
                    sub: "Further secure your account for safety",
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: 25),
                const Text(
                  "More",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                _buildMenuContainer([
                  _buildMenuItem(Icons.notifications_none, "Help & Support"),
                  _buildMenuItem(
                    Icons.favorite_border,
                    "About App",
                    isLast: true,
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Helper to wrap menu items in a white card
  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Helper to build individual menu rows
  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? sub,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.indigo[400], size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: sub != null
              ? Text(
                  sub,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                )
              : null,
          trailing:
              trailing ??
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () {},
        ),
        if (!isLast)
          Divider(
            indent: 70,
            endIndent: 20,
            color: Colors.grey[100],
            height: 1,
          ),
      ],
    );
  }
}
