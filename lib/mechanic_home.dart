import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'login_choice_screen.dart';

class MechanicHome extends StatefulWidget {
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
            child:
                isFetchingLocation
                    ? CircularProgressIndicator()
                    : Text(
                      "Your Location:\nLat: $latitude, Lng: $longitude",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
