import 'dart:async'; // 🔹 Import Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
  User? user = FirebaseAuth.instance.currentUser;
  Timer? _statusUpdateTimer; // ✅ Changed `late` to nullable

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _setOnlineStatus(); // ✅ Set mechanic as "online"
  }

  // ✅ Start real-time location updates
  void _startLocationUpdates() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    if (!serviceEnabled) return;

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    location.onLocationChanged.listen((LocationData locationData) {
      if (mounted) {
        setState(() {
          latitude = locationData.latitude;
          longitude = locationData.longitude;
          isFetchingLocation = false;
        });

        _updateLocationInFirestore();
      }
    });
  }

  // ✅ Store lat/lon in Firestore
  Future<void> _updateLocationInFirestore() async {
    if (user != null && latitude != null && longitude != null) {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "latitude": latitude,
        "longitude": longitude,
      }, SetOptions(merge: true));
    }
  }

  // ✅ Set mechanic as "online" and keep updating the status
  Future<void> _setOnlineStatus() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "status": "online",
      }, SetOptions(merge: true));

      // 🔹 Keep updating the "online" status every 30 seconds to prevent disconnection
      _statusUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .update({"status": "online"});
        }
      });
    }
  }

  // ✅ Set mechanic as "offline" when logging out
  Future<void> _setOfflineStatus() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"status": "offline"});
      } catch (e) {
        print("❌ Firestore Permission Error: $e");
      }
    }
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel(); // ✅ Check before canceling
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mechanic Dashboard"),
        automaticallyImplyLeading: false, // ✅ Removes the back button
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _setOfflineStatus(); // ✅ Mark as "offline" before logout
              await FirebaseAuth.instance.signOut();
              OneSignal.User.removeTag("role");
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
                      "📍 Your Location:\nLat: ${latitude ?? 'Loading...'}, Lng: ${longitude ?? 'Loading...'}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: _startLocationUpdates, // ✅ Refresh location
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // ✅ Center vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ✅ Center horizontally
              children: [
                Text(
                  "Welcome, Mechanic!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // ✅ Center the text
                ),
                SizedBox(height: 10), // 🔹 Space between texts
                Text(
                  "You have no notification",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center, // ✅ Center the text
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
