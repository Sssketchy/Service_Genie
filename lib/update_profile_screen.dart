import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController carNameController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();

  String? selectedCarLogo;

  // Car logos map (Add more car brands here)
  final Map<String, String> carLogos = {
    "Toyota": "assets/car_logos/toyota.png",
    "Honda": "assets/car_logos/honda.png",
    "Ford": "assets/car_logos/ford.png",
    "BMW": "assets/car_logos/bmw.png",
    "Mercedes": "assets/car_logos/mercedes.png",
    "Suzuki": "assets/car_logos/suzuki.png",
    "Hyundai": "assets/car_logos/hyundai.png",
    "Audi": "assets/car_logos/audi.png",
    "Volkswagen": "assets/car_logos/volkswagen.png",
    "Mahindra": "assets/car_logos/mahindra.png",
    "Tata": "assets/car_logos/tata.png",
  };

  void _updateCarLogo(String carName) {
    setState(() {
      selectedCarLogo = carLogos[carName] ?? "assets/car_logos/default.png";
    });
  }

  Future<void> _saveProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("customer_details")
        .doc(user.uid)
        .set({
          "phone": phoneController.text,
          "carName": carNameController.text,
          "carModel": carModelController.text,
          "license": licenseController.text,
          "insurance": insuranceController.text,
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile Updated!")));
  }

  void _showCarSelectionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300, // Adjust height based on content
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Select Car Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: carLogos.keys.length,
                  itemBuilder: (context, index) {
                    String carName = carLogos.keys.elementAt(index);
                    return ListTile(
                      title: Text(carName),
                      onTap: () {
                        setState(() {
                          carNameController.text = carName;
                          _updateCarLogo(carName);
                        });
                        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Car Logo Display
            if (selectedCarLogo != null)
              Image.asset(
                selectedCarLogo!,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),

            SizedBox(height: 20),

            // Form Fields
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    "Phone Number",
                    phoneController,
                    TextInputType.phone,
                  ),
                  SizedBox(height: 15),

                  // Car Name (Now Scrollable)
                  GestureDetector(
                    onTap: _showCarSelectionDialog,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        "Car Name",
                        carNameController,
                        TextInputType.text,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    "Car Model",
                    carModelController,
                    TextInputType.text,
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    "License Number",
                    licenseController,
                    TextInputType.text,
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    "Insurance Number",
                    insuranceController,
                    TextInputType.text,
                  ),
                  SizedBox(height: 25),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }
}
