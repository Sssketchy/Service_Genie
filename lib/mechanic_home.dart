import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'login_choice_screen.dart';
import 'notification_service.dart';

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

  Future<void> _updateRequestStatus(
    String requestId,
    String status,
    String customerId,
  ) async {
    await FirebaseFirestore.instance
        .collection("service_requests")
        .doc(requestId)
        .update({"status": status, "mechanicId": user!.uid});

    // 🔹 Fetch customer's OneSignal Player ID from Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(customerId)
            .get();

    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null || !userData.containsKey("playerId")) {
      print("❌ User has no OneSignal Player ID.");
      return;
    }

    String playerId = userData["playerId"];

    // 🔹 Send notification to the customer
    String notificationMessage =
        (status == "accepted")
            ? "✅ Your service request has been accepted!"
            : "❌ Your service request has been rejected.";

    sendNotificationToUser(
      playerId,
      "Service Request Update",
      notificationMessage,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Request marked as $status.")));
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
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logoutUser)],
      ),
      body: Column(
        children: [
          // Location info
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

          // Service Requests List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("service_requests")
                      .where(
                        "status",
                        isEqualTo: "pending",
                      ) // Show only pending requests
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No service requests at the moment.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                var requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var request = requests[index];
                    Map<String, dynamic> requestData =
                        request.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          "🔧 Service Issue: ${requestData["issue"]}",
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("👤 Customer: ${requestData["customerName"]}"),
                            Text("📞 Phone: ${requestData["phone"]}"),
                            Text(
                              "🚗 Car: ${requestData["carName"]} (${requestData["carModel"]})",
                            ),
                            Text("📄 License: ${requestData["license"]}"),
                            Text("📄 Insurance: ${requestData["insurance"]}"),
                            Text("📝 Details: ${requestData["description"]}"),
                          ],
                        ),
                        trailing: Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed:
                                  () => _updateRequestStatus(
                                    request.id,
                                    "accepted",
                                    requestData["customerId"],
                                  ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed:
                                  () => _updateRequestStatus(
                                    request.id,
                                    "rejected",
                                    requestData["customerId"],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
