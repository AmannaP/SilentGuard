import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
=======
import 'screens/profile.dart';
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/case_history.dart';
<<<<<<< HEAD
import 'screens/home_screen.dart';
import 'screens/map_tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
=======
import 'screens/case_screens.dart';
import 'screens/home_screen.dart';
import 'screens/map_tracking_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/upload_evidence_screen.dart';
import 'screens/record_evidence_screen.dart';
import 'screens/call_screen.dart';

void main() {
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
  runApp(const SilentGuardApp());
}

class SilentGuardApp extends StatelessWidget {
  const SilentGuardApp({super.key});
<<<<<<< HEAD

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silent Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCD7F32)),
      ),
      // Changed initialRoute from '/' to '/home_page'
      initialRoute: '/home_page',
=======
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilentGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.orange),
      // Set the starting page
      initialRoute: '/',
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
      routes: {
        '/': (context) => const LandingPage(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up_page': (context) => const SignUpPage(),
<<<<<<< HEAD
        '/home_page': (context) => const HomeScreen(),
        '/case_history': (context) => const CaseHistory(),
        '/map_tracking': (context) => const MapTrackingScreen(),
      },
    );
  }
}
=======
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
>>>>>>> 7d99e79e84dea3781a33b5662d6f7cf5a88beeef
