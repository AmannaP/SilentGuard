import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/case_history.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/landing_page',
      routes: {
        '/landing_page': (context) => const LandingPage(),
        '/login_page':   (context) => const LoginPage(),
        '/sign_up_page': (context) => const SignUpPage(),
        '/home_page':    (context) => const CaseHistory(),
      },
    );
  }
}