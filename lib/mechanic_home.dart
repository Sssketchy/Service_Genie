import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'login_choice_screen.dart';

class MechanicHome extends StatefulWidget {
  const MechanicHome({super.key});

  @override
  _MechanicHomeState createState() => _MechanicHomeState();
}

class _MechanicHomeState extends State<MechanicHome> {
  double? latitude;
  double? longitude;
  bool isFetchingLocation = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => isFetchingLocation = true);
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print("❌ Location services are disabled.");
        setState(() => isFetchingLocation = false);
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print("❌ Location permission denied.");
        setState(() => isFetchingLocation = false);
        return;
      }
    }

    try {
      LocationData locationData = await location.getLocation();

      // 🔹 Round to 3 decimal places
      double roundedLat = double.parse(
        locationData.latitude!.toStringAsFixed(3),
      );
      double roundedLng = double.parse(
        locationData.longitude!.toStringAsFixed(3),
      );

      print("✅ Mechanic Location: Lat=$roundedLat, Lng=$roundedLng");

      if (mounted) {
        setState(() {
          latitude = roundedLat;
          longitude = roundedLng;
          isFetchingLocation = false;
        });
      }

      // 🔹 Store rounded values in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "latitude": roundedLat,
          "longitude": roundedLng,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("❌ Error getting location: $e");
      setState(() => isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mechanic Dashboard"),
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
      body: Stack(
        children: [
          // Display location at the top left with Refresh Button
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                isFetchingLocation
                    ? CircularProgressIndicator()
                    : Text(
                      "Your Location:\nLat: $latitude, Lng: $longitude",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: _getLocation, // Refresh location when clicked
                ),
              ],
            ),
          ),
          // Main Content
          Center(
            child: Text("Welcome, Mechanic!", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
