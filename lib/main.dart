import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'cart_provider.dart';
import 'marketplace.dart';
import 'login_choice_screen.dart';
import 'login_choice_screen.dart';
import 'customer_home.dart';
import 'mechanic_home.dart';
import 'product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? "");
  OneSignal.Notifications.requestPermission(true);

  runApp(
    ChangeNotifierProvider(create: (context) => CartProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return LoginChoiceScreen();
          }

          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(snapshot.data!.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return LoginChoiceScreen();
                return LoginChoiceScreen();
              }

              String role = userSnapshot.data!["role"];
              return role == "Customer" ? CustomerHome() : MechanicHome();
            },
          );
        },
      ),
    );
  }
}
