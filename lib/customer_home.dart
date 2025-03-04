import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_choice_screen.dart'; // Import login choice screen

class CustomerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginChoiceScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(child: Text("Welcome, Customer!")),
    );
  }
}
