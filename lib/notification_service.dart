import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ✅ Send Notification to a Specific Segment (e.g., All Mechanics)
Future<void> sendNotificationToSegment(
  String segmentName,
  String title,
  String message,
) async {
  String oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? "";
  String restApiKey = dotenv.env['ONESIGNAL_API_KEY'] ?? "";

  final Uri url = Uri.parse("https://onesignal.com/api/v1/notifications");

  final Map<String, dynamic> notificationData = {
    "app_id": oneSignalAppId,
    "filters": [
      {"field": "tag", "key": "role", "relation": "=", "value": segmentName},
    ],
    "headings": {"en": title},
    "contents": {"en": message},
  };

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Key $restApiKey",
    },
    body: jsonEncode(notificationData),
  );

  if (response.statusCode == 200) {
    print("✅ Notification sent to $segmentName successfully!");
  } else {
    print("❌ Failed to send notification: ${response.body}");
  }
}

// ✅ Send Notification to a Specific User (Customer)
Future<void> sendNotificationToUser(
  String playerId,
  String title,
  String message,
) async {
  String oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? "";
  String restApiKey = dotenv.env['ONESIGNAL_API_KEY'] ?? "";

  if (playerId.isEmpty) {
    print("❌ Error: No OneSignal Player ID found for user.");
    return;
  }

  final Uri url = Uri.parse("https://onesignal.com/api/v1/notifications");

  final Map<String, dynamic> notificationData = {
    "app_id": oneSignalAppId,
    "include_player_ids": [playerId], // 🔹 Target a specific user
    "headings": {"en": title},
    "contents": {"en": message},
  };

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Key $restApiKey",
    },
    body: jsonEncode(notificationData),
  );

  if (response.statusCode == 200) {
    print("✅ Notification sent to user successfully!");
  } else {
    print("❌ Failed to send notification: ${response.body}");
  }
}
