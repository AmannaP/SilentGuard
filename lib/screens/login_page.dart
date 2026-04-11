import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/ui_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Color _themeOrange = const Color(0xFFD4833B);
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    if (_emailController.text.trim().isEmpty) {
                      UIUtils.showCustomPopup(
                        context,
                        title: 'Email Required',
                        message: 'Please enter your email address in the field above to reset your password.',
                        isSuccess: false,
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      await AuthService().resetPassword(_emailController.text.trim());
                      if (mounted) {
                        UIUtils.showCustomPopup(
                          context,
                          title: 'Email Sent',
                          message: 'A password reset link has been sent to ${_emailController.text.trim()}.',
                          isSuccess: true,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        UIUtils.showCustomPopup(
                          context,
                          title: 'Error',
                          message: e.toString(),
                          isSuccess: false,
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Login Button (Matches Figma text style)
              Align(
                alignment: Alignment.center,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : TextButton(
                  onPressed: () async {
                    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                      UIUtils.showCustomPopup(
                        context,
                        title: 'Fields Required',
                        message: 'Please fill out both email and password fields.',
                        isSuccess: false,
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      await AuthService().login(_emailController.text.trim(), _passwordController.text.trim());
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/home_page');
                      }
                    } catch (e) {
                      if (mounted) {
                        UIUtils.showCustomPopup(
                          context,
                          title: 'Login Failed',
                          message: e.toString(),
                          isSuccess: false,
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
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
          obscureText: isPassword && !_isPasswordVisible,
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
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
