import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:service_genie/marketplace.dart';
import 'package:service_genie/request_mechanic_page.dart';
import 'package:service_genie/chat_room.dart'; // ✅ Import Chat Room Page
import 'login_choice_screen.dart';
import 'nearby_mechanics_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
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
        await _setOfflineStatus();
        await FirebaseAuth.instance.signOut();
        OneSignal.User.removeTag("role");

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
        title: Text("Customer Dashboard"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logoutUser)],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isFetchingLocation
                      ? CircularProgressIndicator()
                      : Expanded(
                        child: Text(
                          "📍 Your Location:\nLat: ${latitude ?? 'Loading...'}, Lng: ${longitude ?? 'Loading...'}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    onPressed: _startLocationUpdates,
                  ),
                ],
              ),
            ),
          ),
          Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSquareButton("Find Nearby Mechanics", Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NearbyMechanicsScreen(),
                  ),
                );
              }),
              SizedBox(width: 15),
              _buildSquareButton("Map View", Colors.green, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestPage()),
                );
              }),
            ],
          ),

          SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSquareButton("Car Accessories Store", Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MarketplacePage()),
                );
              }),
            ],
          ),

          SizedBox(height: 15),

          // ✅ New "Chat Room" Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSquareButton("Chat Room", Colors.purple, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatRoomPage()),
                );
              }),
            ],
          ),

          Spacer(),
        ],
      ),
    );
  }

  /// 📌 Helper method to build square buttons
  Widget _buildSquareButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
