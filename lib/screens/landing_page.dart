import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bronzeColor = Color(0xFFCD7F32);

    return Scaffold(
      backgroundColor: bronzeColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Image (Full Width)
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              child: Image.asset(
                'asset/landingimg.png',
                fit: BoxFit.cover,
                // Fallback for missing image in preview
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black12,
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  // 2. Title
                  const Text(
                    "Silent Guard",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Subtitle Paragraph
                  const Text(
                    "A mobile application built with love to support the good service of the Renel Ghana.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87, // Fixed typo from 'blackde87'
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 4. Login & Sign Up Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login_page'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/sign_up_page'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[600],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 5. Emergency Report Button (With Shadow)
                  Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic for quick emergency report
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Make an Emergency Report",
                        style: TextStyle(
                          color: bronzeColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 6. Social Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.facebook,
                          color: Colors.blue,
                          size: 40,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.orange,
                          size: 35,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.apple,
                          color: Colors.black,
                          size: 45,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 7. Footer text
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/sign_up_page'),
                    child: const Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    color: Colors.black45,
                    thickness: 0.5,
                    indent: 40,
                    endIndent: 40,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "@SilentGuard in Partnership with Renel Ghana Foundation\n2026. Reserves Copyright laws.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
