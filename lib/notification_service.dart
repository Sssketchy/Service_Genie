import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendNotificationToSegment(String title, String message) async {
  String oneSignalAppId =
      dotenv.env['ONESIGNAL_APP_ID'] ??
      ""; // Replace with your OneSignal App ID
  String restApiKey =
      dotenv.env['ONESIGNAL_API_KEY'] ??
      ""; // Replace with your OneSignal REST API Key

  final Uri url = Uri.parse("https://onesignal.com/api/v1/notifications");

  final Map<String, dynamic> notificationData = {
    "app_id": oneSignalAppId,
    "filters": [
      {"field": "tag", "key": "role", "relation": "=", "value": "Mechanic"},
    ],
    "headings": {"en": title}, // Notification title
    "contents": {"en": message}, // Notification message
  };

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization":
          "Key ${dotenv.env['ONESIGNAL_API_KEY']}", // OneSignal REST API Key
    },
    body: jsonEncode(notificationData),
  );

  if (response.statusCode == 200) {
    print("Notification sent successfully!");
  } else {
    print("Failed to send notification: ${response.body}");
  }
}
