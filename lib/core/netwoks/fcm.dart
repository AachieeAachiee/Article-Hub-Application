import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final String projectId;

  FCMService({required this.projectId});

  /// Load service account from JSON and get auth client
  Future<AuthClient> _getAuthClient() async {
    final jsonString = await File('assets/serviceAccount.json').readAsString();
    final credentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonString));
    final client = await clientViaServiceAccount(credentials, _scopes);
    return client;
  }

  /// Send push notification via FCM V1 API
  Future<void> sendPush({
    required String title,
    required String body,
    required String token,
    String? articleId,
  }) async {
    final client = await _getAuthClient();

    final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final payload = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "articleId": articleId ?? "",
        }
      }
    };

    final response = await client.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    print("FCM Response: ${response.body}");
  }
}

