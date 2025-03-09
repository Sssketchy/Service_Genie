// login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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

  Future<void> saveFCMToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "fcmToken": token,
      });
    }
  }

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ Login Successful: ${userCredential.user!.uid}");

      await saveFCMToken(userCredential.user!.uid);

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

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: "no-user-data",
          message: "User data missing in Firestore.",
        );
      }

      String role = userDoc["role"];

      OneSignal.User.addTagWithKey("role", role);

      if (role == widget.userRole) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    role == "Customer" ? CustomerHome() : MechanicHome(),
          ),
        );
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      print("❌ Unexpected Error: $e");
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
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/handshake.webp", // Keep your wallpaper
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Centered Login Box
          Center(
            child: Container(
              padding: EdgeInsets.all(25),
              width: 350, // Adjust width to fit content
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7), // ✅ Slight transparency
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Black Box for Mechanic Login (Full Width)
                  Container(
                    width: double.infinity, // Make it take full width
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black, // Black background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "${widget.userRole} Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text inside black box
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // ✅ Email TextField
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100], // Light grey fill
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

                  // ✅ Password TextField
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
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

                  // ✅ Login Button
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
