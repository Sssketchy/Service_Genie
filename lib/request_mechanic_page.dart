import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'notification_service.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String? selectedIssue;
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> issues = [
    {"name": "Engine Failure", "image": "assets/list_icons/engine.png"},
    {"name": "Flat Tyre", "image": "assets/list_icons/engine.png"},
    {"name": "Battery Down", "image": "assets/list_icons/engine.png"},
    {"name": "Fluid Leak", "image": "assets/list_icons/engine.png"},
    {"name": "Tow Service", "image": "assets/list_icons/engine.png"},
    {"name": "Starting Issue", "image": "assets/list_icons/engine.png"},
    {"name": "Gear Failure", "image": "assets/list_icons/engine.png"},
    {"name": "Braking Problem", "image": "assets/list_icons/engine.png"},
    {"name": "Out of Fuel", "image": "assets/list_icons/engine.png"},
  ];

  // 🔹 Function to show scrollable issue list
  void _showIssueSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300, // ✅ Restrict height
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Select Issue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.asset(
                        issues[index]["image"]!,
                        width: 30,
                        height: 30,
                      ),
                      title: Text(issues[index]["name"]!),
                      onTap: () {
                        setState(() {
                          selectedIssue = issues[index]["name"];
                        });
                        Navigator.pop(context); // ✅ Close the sheet
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Function to send request & store in Firestore
  Future<void> _sendServiceRequest() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch customer details from Firestore
    DocumentSnapshot customerSnapshot =
        await FirebaseFirestore.instance
            .collection("customer_details")
            .doc(user.uid)
            .get();

    if (!customerSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please update your profile first!")),
      );
      return;
    }

    Map<String, dynamic> customerData =
        customerSnapshot.data() as Map<String, dynamic>;

    String customerName = customerData["name"] ?? "Unknown";
    String phone = customerData["phone"] ?? "No phone number";
    String carName = customerData["carName"] ?? "Unknown";
    String carModel = customerData["carModel"] ?? "Unknown";
    String license = customerData["license"] ?? "N/A";
    String insurance = customerData["insurance"] ?? "N/A";

    // Store request in Firestore
    await FirebaseFirestore.instance.collection("service_requests").add({
      "customerId": user.uid,
      "customerName": customerName,
      "phone": phone,
      "carName": carName,
      "carModel": carModel,
      "issue": selectedIssue ?? "Unknown Issue",
      "description": _descriptionController.text,
      "license": license,
      "insurance": insurance,
      "status": "pending", // Initially pending
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Send notification to nearby mechanics
    sendNotificationToSegment(
      "Mechanic",
      "🚨 Service Request: $selectedIssue",
      "Customer $customerName needs help with $selectedIssue. Check now!",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Service Request Sent Successfully!")),
    );

    // Clear input fields after sending request
    setState(() {
      selectedIssue = null;
      _descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Service")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Map Placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text("Map", style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 20),

              // Scrollable Issue Selection
              GestureDetector(
                onTap: _showIssueSelection,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedIssue ?? "Select Issue",
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Text Field for Issue Description
              SizedBox(
                height: 150,
                child: TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: "Describe your issue",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Request Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendServiceRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    "Request Service",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
