import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'login_choice_screen.dart';
import 'mechanic_profile_screen.dart';
import 'notification_service.dart';

class MechanicHome extends StatefulWidget {
  const MechanicHome({super.key});

  @override
  _MechanicHomeState createState() => _MechanicHomeState();
}

class _MechanicHomeState extends State<MechanicHome> {
  double? latitude, longitude;
  bool isFetchingLocation = true;
  String? mechanicName; // 🔹 Stores mechanic's name
  final Location location = Location();
  final User? user = FirebaseAuth.instance.currentUser;
  Timer? _statusUpdateTimer;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _updateStatus("online");
    _fetchMechanicName();
  }

  /// 🔹 Fetch the mechanic's name from Firestore
  Future<void> _fetchMechanicName() async {
    if (user == null) return;

    DocumentSnapshot mechanicDoc =
        await FirebaseFirestore.instance
            .collection("mechanic_details")
            .doc(user!.uid)
            .get();

    if (mechanicDoc.exists) {
      setState(() {
        mechanicName = mechanicDoc["name"];
      });
    } else {
      _askForMechanicName();
    }
  }

  /// 🔹 Ask the mechanic to enter their name if missing
  void _askForMechanicName() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text("Enter Your Name"),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Enter your full name"),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  String enteredName = nameController.text.trim();
                  if (enteredName.isNotEmpty && user != null) {
                    await FirebaseFirestore.instance
                        .collection("mechanic_details")
                        .doc(user!.uid)
                        .set({"name": enteredName}, SetOptions(merge: true));

                    // 🔹 Refresh the page after saving
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MechanicHome()),
                    );
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }

  void _startLocationUpdates() async {
    if (!(await location.serviceEnabled()) &&
        !(await location.requestService()))
      return;
    if (await location.hasPermission() == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted)
      return;

    _locationSubscription?.cancel();
    _locationSubscription = location.onLocationChanged.listen((loc) {
      if (mounted) {
        setState(() {
          latitude = loc.latitude;
          longitude = loc.longitude;
          isFetchingLocation = false;
        });
        _updateFirestore({"latitude": latitude, "longitude": longitude});
      }
    });
  }

  Future<void> _updateFirestore(Map<String, dynamic> data) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> _updateStatus(String status) async {
    await _updateFirestore({"status": status});
    if (status == "online") {
      _statusUpdateTimer = Timer.periodic(
        Duration(seconds: 30),
        (_) => _updateFirestore({"status": "online"}),
      );
    }
  }

  @override
  void dispose() {
    _updateStatus("offline");
    _statusUpdateTimer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mechanic Dashboard"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Column(
        children: [
          _buildMechanicInfo(),
          _buildLocationInfo(),
          _buildUpdateProfileButton(context),
          Expanded(child: _buildServiceRequests()),
        ],
      ),
    );
  }

  /// 🔹 Display the mechanic's name on the dashboard
  Widget _buildMechanicInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "👨‍🔧 Mechanic: ${mechanicName ?? 'Loading...'}",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isFetchingLocation
              ? CircularProgressIndicator()
              : Expanded(
                child: Text(
                  "📍 Your Location:\nLat: ${latitude ?? 'Loading...'}, Lng: ${longitude ?? 'Loading...'}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: _startLocationUpdates,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateProfileButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MechanicProfileScreen()),
            ).then((_) => _fetchMechanicName()), // 🔹 Refresh name after update
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          "Update Profile",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildServiceRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("service_requests")
              .where("status", isEqualTo: "pending")
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No service requests.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView(
          children:
              snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return _buildServiceRequestCard(doc.id, data);
              }).toList(),
        );
      },
    );
  }

  Widget _buildServiceRequestCard(String requestId, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestInfo("🔧 Service Issue", data["issue"]),
            _buildRequestInfo("👤 Customer", data["customerName"]),
            _buildRequestInfo("📞 Phone", data["phone"]),
            _buildRequestInfo(
              "🚗 Car",
              "${data["carName"]} (${data["carModel"]})",
            ),
            _buildRequestInfo("📄 License", data["license"]),
            _buildRequestInfo("📄 Insurance", data["insurance"]),
            _buildRequestInfo("📝 Details", data["description"]),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestInfo(String label, String? value) {
    return Text("$label: ${value ?? 'N/A'}", style: TextStyle(fontSize: 14));
  }

  Future<void> _logout() async {
    await _updateStatus("offline");
    await FirebaseAuth.instance.signOut();
    OneSignal.User.removeTag("role");
    if (mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginChoiceScreen()),
      );
  }
}
