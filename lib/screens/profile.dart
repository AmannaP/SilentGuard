import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/auth_service.dart';
import '../utils/ui_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _themeOrange = const Color(0xFFD4833B);
  String _fullName = "Loading...";
  String _email = "Loading...";
  String _phoneNumber = "";
  String _photoUrl = "";
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
       try {
         final doc = await AuthService().getUserData(uid);
         if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            if (mounted) {
              setState(() {
                 _fullName = data['fullName'] ?? 'Unknown User';
                 _email = data['email'] ?? 'Unknown Email';
                 _photoUrl = data['photoUrl'] ?? '';
                 _phoneNumber = data['phoneNumber'] ?? '';
              });
            }
          } else {
             if (mounted) setState(() { _fullName = 'User not found'; _email = 'Check connection'; });
          }
       } catch (e) {
         debugPrint("Profile load error: $e");
         if (mounted) setState(() { _fullName = 'Profile Error'; _email = 'Network failure'; });
       }
    } else {
       if (mounted) setState(() { _fullName = 'Guest'; _email = 'Not signed in'; });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (image == null) return;

    setState(() => _isUploading = true);
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pics').child('$uid.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      
      await AuthService().updateUserData(uid, {'photoUrl': url});
      setState(() => _photoUrl = url);
      
      if (mounted) {
        UIUtils.showCustomPopup(context, title: 'Success', message: 'Profile picture updated!', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showCustomPopup(context, title: 'Upload Failed', message: e.toString(), isSuccess: false);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showEditDialog(String title, String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: 'Enter $title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final uid = AuthService().currentUser?.uid;
              if (uid != null) {
                await AuthService().updateUserData(uid, {field: controller.text.trim()});
                _loadUserData();
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


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
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white24,
                        backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                        child: _photoUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white54) : null,
                      ),
                      if (_isUploading) const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _email,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditDialog('Name', 'fullName', _fullName),
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
                    onTap: () => _showEditDialog('Name', 'fullName', _fullName),
                    trailing: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  _buildMenuItem(
                    Icons.people_outline,
                    "Phone Number",
                    sub: _phoneNumber.isEmpty ? "Add your phone number" : _phoneNumber,
                    onTap: () => _showEditDialog('Phone Number', 'phoneNumber', _phoneNumber),
                  ),
                  _buildMenuItem(
                    Icons.lock_outline,
                    "Face ID / Touch ID",
                    sub: "Feature coming soon",
                    trailing: Switch(value: false, onChanged: null), // Disabled
                  ),
                  _buildMenuItem(
                    Icons.verified_user_outlined,
                    "Two-Factor Authentication",
                    sub: "Feature coming soon",
                  ),
                  _buildMenuItem(
                    Icons.logout,
                    "Log out",
                    sub: "Sign out of your account",
                    isLast: true,
                    onTap: () async {
                      await AuthService().logout();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login_page', (route) => false);
                      }
                    }
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
                  _buildMenuItem(
                    Icons.help_outline, 
                    "Help & Support",
                    onTap: () => Navigator.pushNamed(context, '/help_support'),
                  ),
                  _buildMenuItem(
                    Icons.info_outline,
                    "About App",
                    isLast: true,
                    onTap: () => Navigator.pushNamed(context, '/about_app'),
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
    VoidCallback? onTap,
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
          onTap: onTap ?? () {},
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
