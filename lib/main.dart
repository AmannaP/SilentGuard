import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/decoy_page.dart';

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
        '/home_page': (context) => const RealDashboard(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display image from assets
            git SizedBox(
              width: double.infinity,
              height:
                  MediaQuery.of(context).size.height *
                  0.2, // Takes 20% of screen height
              child: Image.asset(
                'asset/landingimg.png',
                fit: BoxFit
                    .cover, // This stretches/crops to fill the entire box width
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "SilentGuard Page",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
            // Space between buttons
            const SizedBox(height: 16),

            const Text(
              'A mobile application built with love to support the good service of the Renel Ghana.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, // This makes the button fill the width
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/sign_up_page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Get Started"),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login_page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // This makes the button fill the width
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/sign_up_page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Make an Emergency Report"),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () => Navigator.pushNamed(context, '/signup'),
            //   child: const Text("Get Started"),
            // ),
            // TextButton(
            //   onPressed: () => Navigator.pushNamed(context, '/login'),
            //   child: const Text("Already have a PIN? Login"),
            // ),
          ],
        ),
      ),
    );
  }
}
