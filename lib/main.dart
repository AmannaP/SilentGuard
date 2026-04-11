import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'screens/profile.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/case_history.dart';
import 'screens/home_screen.dart';
import 'screens/map_tracking_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/upload_evidence_screen.dart';
import 'screens/record_evidence_screen.dart';
import 'screens/call_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/rep_dashboard.dart';
import 'screens/chat_provider_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await NotificationService().init();
  } catch (e) {
    debugPrint("Initialization failed: $e");
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
      home: const SilentGuardRoot(),
      routes: {
        '/landing_page': (context) => const LandingPage(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up_page': (context) => const SignUpPage(),
        '/profile': (context) => const ProfilePage(),
        '/case_history': (context) => const CaseHistory(),
        '/home_page': (context) => const HomeScreen(),
        '/map_tracking': (context) => const MapTrackingScreen(),
        '/rep_dashboard': (context) => const RepDashboard(),
        '/archive_screen': (context) => const ArchiveScreen(),
        '/call_screen': (context) => const CallScreen(),
        '/upload_evidence_screen': (context) => const UploadEvidenceScreen(),
        '/record_evidence_screen': (context) => const RecordEvidenceScreen(),
        '/contacts_screen': (context) => const ContactsScreen(),
        '/chat_provider': (context) {
           final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
           return ChatProviderScreen(providerData: args);
        },
      },
    );
  }
}

class SilentGuardRoot extends StatelessWidget {
  const SilentGuardRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String>(
            future: AuthService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (roleSnapshot.data == 'rep') {
                return const RepDashboard();
              }
              return const HomeScreen();
            },
          );
        }
        return const LandingPage();
      },
    );
  }
}
