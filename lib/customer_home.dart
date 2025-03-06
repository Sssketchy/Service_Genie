import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'login_choice_screen.dart';
import 'nearby_mechanics_screen.dart'; // Import the new screen

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
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
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (mounted) setState(() => isFetchingLocation = false);
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) setState(() => isFetchingLocation = false);
        return;
      }
    }

    try {
      LocationData locationData = await location.getLocation();
      if (mounted) {
        setState(() {
          latitude = locationData.latitude;
          longitude = locationData.longitude;
          isFetchingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isFetchingLocation = false);
    }
  }

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
                  onPressed: _getLocation,
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome, Customer!", style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),

                // Button to navigate to the "List of Mechanics Nearby" screen
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NearbyMechanicsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Find Nearby Mechanics",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Feature 2 Button (Friend's work)
                ElevatedButton(
                  onPressed: () {
                    // TODO: Friend's feature logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Feature 2 (Friend's Work)",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
