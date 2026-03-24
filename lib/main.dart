import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/case_history.dart';
import 'screens/map_tracking_screen.dart';
import 'screens/home_screen.dart';
import 'screens/case_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up_page': (context) => const SignUpPage(),
        '/home_screen': (context) => const HomeScreen(),
        '/case_history': (context) => const CaseHistory(),
        '/map_tracking_screen': (context) => const MapTrackingScreen(),
      },
    );
  }
}