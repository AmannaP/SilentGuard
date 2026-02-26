import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();

  void _handleLogin() {
    String pin = _pinController.text;
    if (pin == "1234") {
      // Navigate to Real SOS Dashboard
      Navigator.pushReplacementNamed(context, '/home');
    } else if (pin == "0000") {
      // Navigate to Decoy News Screen
      Navigator.pushReplacementNamed(context, '/decoy');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Access Denied")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Security PIN",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "****",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _handleLogin, child: Text("Enter")),
            TextButton(
              onPressed: () {},
              child: Text(
                "Emergency SOS Call",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
