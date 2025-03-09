import 'dart:async';
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
  Timer? _statusUpdateTimer;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _setOnlineStatus();
  }

  void _startLocationUpdates() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    if (!serviceEnabled) return;

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSubscription?.cancel();
    _locationSubscription = location.onLocationChanged.listen((
      LocationData locationData,
    ) {
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

  Future<void> _updateLocationInFirestore() async {
    if (user != null && latitude != null && longitude != null) {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "latitude": latitude,
        "longitude": longitude,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _logoutUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        // ✅ Set offline status before logging out
        await _setOfflineStatus();

        // ✅ Sign out user from Firebase
        await FirebaseAuth.instance.signOut();

        // ✅ Remove OneSignal tag
        OneSignal.User.removeTag("role");

        // ✅ Navigate to Login screen safely
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginChoiceScreen()),
          );
        }
      } catch (e) {
        print("❌ Logout Error: $e");
      }
    }
  }

  Future<void> _setOnlineStatus() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "status": "online",
      }, SetOptions(merge: true));

      _statusUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
        if (mounted && user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .update({"status": "online"});
        }
      });
    }
  }

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
    _setOfflineStatus();
    _statusUpdateTimer?.cancel();
    _locationSubscription?.cancel();
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
            onPressed: _logoutUser, // ✅ Calls logout function
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: _startLocationUpdates,
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome, Mechanic!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "You have no notification",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
