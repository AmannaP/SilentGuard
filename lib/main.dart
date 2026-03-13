import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/case_history.dart';

void main() {
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/sign_up_page': (context) => const SignUpPage(),
      },
    );
  }
}
