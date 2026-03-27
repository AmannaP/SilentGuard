import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Color _themeOrange = const Color(0xFFD4833B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.black,
                child: Icon(Icons.shield, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Please Login to Continue.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 50),

              // Reusing your white field style
              _buildLoginField("Email", _emailController),
              _buildLoginField(
                "Password",
                _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              // Login Button (Matches Figma text style)
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    // Your login logic here
                    Navigator.pushNamed(context, '/home_page');
                    // Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Login ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white.withOpacity(0.5),
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
