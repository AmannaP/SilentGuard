import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/login_page.dart';
// import 'screens/home_page.dart';

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
      // 1. Defining the App Theme based on Renel Ghana branding
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFCD7F32),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF100F0F),
          primary: const Color(0xFF100F0F),
          secondary: const Color(0xFFFFFFFF),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),

      // 2. Setting the initial route (The Landing Page)
      initialRoute: '/',

      // 3. The Navigation Route Table
      routes: {
        '/': (context) => const LandingPage(),
        '/sign_up_page': (context) => const SignUpPage(),
        '/login_page': (context) => const LoginPage(),
        // '/home_page': (context) => const RealDashboard(),
      },
    );
  }
}
