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
  Location location = Location();
  late Stream<LocationData> locationStream;

  @override
  void initState() {
    super.initState();
    _startListeningToLocation(); // ✅ Start real-time location updates
  }

  void _startListeningToLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // ✅ Listen for real-time location updates
    locationStream = location.onLocationChanged;
    locationStream.listen((LocationData currentLocation) async {
      setState(() {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
        isFetchingLocation = false;
      });

      // ✅ Store updated location in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "latitude": latitude,
          "longitude": longitude,
        }, SetOptions(merge: true));
      }
    });
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
                  onPressed:
                      _startListeningToLocation, // ✅ Refresh location manually
                ),
              ],
            ),
          ),
          Center(
            child: Text("Welcome, Mechanic!", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
