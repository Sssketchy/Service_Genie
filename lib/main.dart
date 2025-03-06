// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login_choice_screen.dart'; // First screen with role selection
import 'customer_home.dart';
import 'mechanic_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // If no user is logged in, show the login choice screen
          if (!snapshot.hasData || snapshot.data == null) {
            return LoginChoiceScreen();
          }

          // Fetch user role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(snapshot.data!.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return LoginChoiceScreen(); // If no role found, send back to login choice
              }

              String role = userSnapshot.data!["role"];
              return role == "Customer" ? CustomerHome() : MechanicHome();
            },
          );
        },
      ),
    );
  }
}
