import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "", email = "", password = "", role = "Customer";
  bool isLoading = false;

  Future<void> signUp() async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("All fields are required!")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ Create user in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // ✅ Store user data in Firestore
      await _firestore.collection("users").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "role": role,
        "status": "online", // Set default status to online after signup
      });

      print("✅ Signup successful for $email");

      // ✅ Navigate to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(userRole: role)),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Successful! Please Login.")),
      );
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Signup Error: ${e.code} - ${e.message}");

      String errorMessage = "Signup failed. Try again.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered. Try logging in!";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak. Try a stronger one.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      print("❌ Unexpected Signup Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade700, Colors.red.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Title Box with Black Background
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$role Sign Up",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ✅ Name Field
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Full Name",
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => name = value,
                ),
                SizedBox(height: 15),

                // ✅ Email Field
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    prefixIcon: Icon(Icons.email, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => email = value,
                ),
                SizedBox(height: 15),

                // ✅ Password Field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => password = value,
                ),
                SizedBox(height: 15),

                // ✅ Role Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: role,
                      dropdownColor: Colors.white,
                      items:
                          ["Customer", "Mechanic"].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) => setState(() => role = value!),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ✅ Signup Button
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: signUp,
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
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
