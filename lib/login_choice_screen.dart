// login_choice_screen.dart
import 'dart:ui'; // Required for ImageFilter.blur
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/background.webp", // Replace with your file name
              fit: BoxFit.cover,
            ),
          ),

          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ), // Adjust blur intensity
              child: Container(
                color: Colors.black.withOpacity(0),
              ), // Transparent overlay
            ),
          ),

          // UI Elements
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome to ServiceGenie",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Customer Login Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LoginScreen(userRole: "Customer"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                      backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Customer ",
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 2, 2, 2),
                          ),
                        ),
                        Icon(
                          Icons.account_circle_outlined,
                          color: const Color.fromARGB(255, 34, 35, 35),
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Mechanic Login Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LoginScreen(userRole: "Mechanic"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Mechanic ",
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 7, 7, 7),
                          ),
                        ),
                        Icon(
                          Icons.build_outlined,
                          color: const Color.fromARGB(255, 17, 17, 17),
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Sign Up Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 214, 222, 224),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
