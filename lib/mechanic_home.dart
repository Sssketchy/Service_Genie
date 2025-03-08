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
    setState(() {
      isFetchingLocation = true; // Start loading before fetching location
    });

    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      setState(() => isFetchingLocation = false);
      return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => isFetchingLocation = false);
        return;
      }
    }

    try {
      LocationData locationData = await location.getLocation();
      double? newLatitude = locationData.latitude;
      double? newLongitude = locationData.longitude;

      if (newLatitude != null && newLongitude != null) {
        setState(() {
          latitude = newLatitude;
          longitude = newLongitude;
          isFetchingLocation = false;
        });

        // ✅ Store location in Firestore
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .set({
                "latitude": latitude,
                "longitude": longitude,
              }, SetOptions(merge: true));
        }
      } else {
        setState(() => isFetchingLocation = false);
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
        title: const Text("Mechanic Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginChoiceScreen(),
                ),
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
                    ? const CircularProgressIndicator()
                    : Text(
                      "Your Location:\nLat: ${latitude?.toStringAsFixed(5) ?? 'N/A'}, "
                      "Lng: ${longitude?.toStringAsFixed(5) ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  onPressed: _getLocation, // Refresh location when clicked
                ),
              ],
            ),
          ),
          // Main Content
          const Center(
            child: Text("Welcome, Mechanic!", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
