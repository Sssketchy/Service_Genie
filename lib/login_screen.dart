// login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'customer_home.dart';
import 'mechanic_home.dart';

class LoginScreen extends StatefulWidget {
  final String userRole; // Accepts role from previous screen

  const LoginScreen({super.key, required this.userRole});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = "", password = "";
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ Login Successful: ${userCredential.user!.uid}");

      // Fetch role from Firestore
      DocumentSnapshot userDoc =
          await _firestore
              .collection("users")
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: "no-user-data",
          message: "User data missing in Firestore.",
        );
      }

      String role = userDoc["role"];

      if (role == widget.userRole) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    role == "Customer" ? CustomerHome() : MechanicHome(),
          ),
        );
      } else {
        throw FirebaseAuthException(
          code: "wrong-role",
          message: "Incorrect role selected for this account.",
        );
      }
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");

      String errorMessage = "Login failed. Check your credentials.";
      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email. Please sign up.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Enter a valid email address.";
      } else if (e.code == 'wrong-role') {
        errorMessage = "You selected the wrong role. Try again.";
      } else if (e.code == 'no-user-data') {
        errorMessage = "User data is missing in Firestore.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      print("❌ Unexpected Error: $e"); // Print the full error in console
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/handshake.webp", // Replace with your image file
              fit: BoxFit.cover,
            ),
          ),

          // Login UI
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${widget.userRole} Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email TextField
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Enter Email",
                      prefixIcon: Icon(Icons.email, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => email = value,
                  ),
                  SizedBox(height: 15),

                  // Password TextField
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Enter Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => password = value,
                  ),
                  SizedBox(height: 20),

                  // Login Button
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 40,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
