import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("My Orders 📦")),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: userId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders found 😕"));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children:
                snapshot.data!.docs.map((order) {
                  var data = order.data() as Map<String, dynamic>;
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Order: ${data['name']}"),
                      subtitle: Text(
                        "Address: ${data['address']}\nPhone: ${data['phone']}",
                      ),
                      trailing: Text(
                        "📅 ${data['timestamp']?.toDate().toLocal().toString().split('.')[0]}",
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
