import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'notification_service.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String? selectedItem;
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> items = [
    {"name": "Engine Failure", "image": "assets/list_icons/engine.png"},
    {"name": "Flat Tyre", "image": "assets/list_icons/engine.png"},
    {"name": "Battery Down", "image": "assets/list_icons/engine.png"},
  ];

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

              // Dropdown List
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedItem,
                    hint: Text("Select Issue"),
                    items:
                        items.map((item) {
                          return DropdownMenuItem<String>(
                            value: item["name"],
                            child: Row(
                              children: [
                                Image.asset(
                                  item["image"]!,
                                  width: 30,
                                  height: 30,
                                ),
                                SizedBox(width: 10),
                                Text(item["name"]!),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Text Field
              SizedBox(
                height: 150, // Adjust height as needed
                child: TextField(
                  controller: _textController,
                  maxLines:
                      null, // Allows unlimited lines within the given height
                  expands: true, // Makes it fill the parent SizedBox
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
                  onPressed: () {
                    print(
                      "Request sent for $selectedItem with details: ${_textController.text}",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5,
                      ), // Less curved edges
                    ),
                  ),
                  child: Text(
                    "Request",
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print(
                      "Request sent for $selectedItem with details: ${_textController.text}",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24, // Background color
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5,
                      ), // Less curved edges
                    ),
                  ),
                  child: Text(
                    "Find Mechanics",
                    style: TextStyle(
                      color: Colors.blue, // White text
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
