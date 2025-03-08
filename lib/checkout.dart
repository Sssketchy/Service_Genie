import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'order_confirmation.dart'; // Import Order Confirmation Page

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'name': nameController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'paymentMethod': 'Cash on Delivery',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => isLoading = false);

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order placed successfully! 🎉")));

      // Navigate to Order Confirmation Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderConfirmationPage()),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error placing order: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Delivery Address"),
                validator:
                    (value) => value!.isEmpty ? "Enter delivery address" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value!.length < 10 ? "Enter valid phone number" : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: () {
                      print("Order button clicked"); // Debugging
                      _confirmOrder();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                    ),
                    child: Text(
                      "Confirm Order",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
