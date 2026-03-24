import 'package:flutter/material.dart';
import 'screens/profile.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/case_history.dart';
import 'screens/case_screens.dart';
import 'screens/home_screen.dart';
import 'screens/map_tracking_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/upload_evidence_screen.dart';
import 'screens/record_evidence_screen.dart';
import 'screens/call_screen.dart';

void main() {
  runApp(const SilentGuardApp());
}

class SilentGuardApp extends StatelessWidget {
  const SilentGuardApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilentGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.orange),
      // Set the starting page
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up_page': (context) => const SignUpPage(),
        '/case_screens': (context) => const CaseScreens(),
        '/profile': (context) => const ProfilePage(),
        '/case_history': (context) => const CaseHistory(),
        '/home_screen': (context) => const HomeScreen(),
        '/map_tracking_screen': (context) => const MapTrackingScreen(),
        '/archive_screen': (context) => const ArchiveScreen(),
        '/call_screen': (context) => const CallScreen(),
        '/upload_evidence_screen': (context) => const UploadEvidenceScreen(),
        '/record_evidence_screen': (context) => const RecordEvidenceScreen(),
      },

    );
  }
}