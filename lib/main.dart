import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/case_history.dart';
import 'screens/home_screen.dart';
import 'screens/map_tracking_screen.dart';

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
      // Changed initialRoute from '/' to '/home_page'
      initialRoute: '/home_page',
      routes: {
        '/': (context) => const LandingPage(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up_page': (context) => const SignUpPage(),
        '/home_page': (context) => const HomeScreen(),
        '/case_history': (context) => const CaseHistory(),
        '/map_tracking': (context) => const MapTrackingScreen(),
      },
    );
  }
}
