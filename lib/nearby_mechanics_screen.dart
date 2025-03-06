import 'package:flutter/material.dart';

class NearbyMechanicsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Mechanics")),
      body: Column(
        children: [
          SizedBox(height: 20), // Adds space from the top
          Center(
            child: Text(
              "List of Mechanics Nearby",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20), // Space below the title
          // Placeholder for the mechanic list
          Expanded(
            child: Center(
              child: Text(
                "No mechanics found yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
