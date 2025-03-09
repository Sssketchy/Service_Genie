import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NearbyMechanicsScreen extends StatelessWidget {
  const NearbyMechanicsScreen({super.key});

  // 🔹 Function to get an address from lat/lng using Nominatim API
  Future<String> _getAddressFromLatLng(double? lat, double? lon) async {
    if (lat == null || lon == null) return "Location not available";

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json",
    );

    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "FlutterApp"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? "Address not found";
      } else {
        return "Error fetching address";
      }
    } catch (e) {
      print("❌ Error fetching address: $e");
      return "Error fetching address";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Mechanics")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              "List of Mechanics Nearby",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("users")
                      .where("role", isEqualTo: "Mechanic")
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No mechanics found.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                var mechanics = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: mechanics.length,
                  itemBuilder: (context, index) {
                    var mechanic =
                        mechanics[index].data() as Map<String, dynamic>;

                    String name = mechanic["name"] ?? "Unknown";
                    String email = mechanic["email"] ?? "No email provided";
                    String status = mechanic["status"] ?? "offline";
                    double? lat = mechanic["latitude"];
                    double? lon = mechanic["longitude"];
                    bool isOnline = status == "online";

                    return FutureBuilder<String>(
                      future: _getAddressFromLatLng(lat, lon),
                      builder: (context, addressSnapshot) {
                        String address =
                            addressSnapshot.data ?? "Fetching address...";

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isOnline ? Colors.green : Colors.red,
                              radius: 10,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOnline ? "🟢 Online" : "🔴 Offline",
                                  style: TextStyle(
                                    color: isOnline ? Colors.green : Colors.red,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text("📍 Address: $address"),
                                Text("📧 Email: $email"),
                              ],
                            ),
                          ),
                        );
                      },
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
