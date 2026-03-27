import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const SilentGuardApp());
}

class SilentGuardApp extends StatelessWidget {
  const SilentGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silent Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCD7F32)),
      ),
      // Set the starting page
      initialRoute: '/home_page',
      routes: {
        '/': (context) => const LandingPage(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up_page': (context) => const SignUpPage(),
        '/case_screens': (context) => const CaseScreens(),
        '/profile': (context) => const ProfilePage(),
        '/case_history': (context) => const CaseHistory(),
        '/home_page': (context) => const HomeScreen(),
        '/map_tracking': (context) => const MapTrackingScreen(),
        '/archive_screen': (context) => const ArchiveScreen(),
        '/call_screen': (context) => const CallScreen(),
        '/upload_evidence_screen': (context) => const UploadEvidenceScreen(),
        '/record_evidence_screen': (context) => const RecordEvidenceScreen(),
      },
    );
  }
}
