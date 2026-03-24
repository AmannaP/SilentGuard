import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home,
              label: "Home",
              isActive: currentIndex == 0,
              route: '/home_screen',
            ),
            _buildNavItem(
              context,
              icon: Icons.history,
              label: "History",
              isActive: currentIndex == 1,
              route: '/case_history',
            ),
            _buildNavItem(
              context,
              icon: Icons.archive_outlined,
              label: "Archive",
              isActive: currentIndex == 2,
              route: '/archive_screen',
            ),
            _buildNavItem(
              context,
              icon: Icons.person_outline,
              label: "Profile",
              isActive: currentIndex == 3,
              route: '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required String route,
  }) {
    final themeOrange = const Color(0xFFD4793A);
    final color = isActive ? themeOrange : Colors.grey;
    final fontWeight = isActive ? FontWeight.bold : FontWeight.normal;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
