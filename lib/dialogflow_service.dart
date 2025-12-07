import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart'; // ✅ Add this package

class DialogflowService {
  static Future<String> sendMessage(String query) async {
    // Load service account credentials
    final serviceAccount = jsonDecode(
      await rootBundle.loadString('assets/credentials/v-connectmuet-aivd-1e2390c11da0.json'),
    );

    final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

    // Request access token
    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    final String projectId = serviceAccount['project_id'];
    final apiUrl =
        'https://dialogflow.googleapis.com/v2/projects/v-connect-muet-cf44b/agent/sessions/123456789:detectIntent';

    // Send message to Dialogflow
    final response = await client.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        "queryInput": {
          "text": {"text": query, "languageCode": "en"}
        }
      }),
    );

    final body = jsonDecode(response.body);

    // Handle errors or missing fields
    final fulfillmentText = body['queryResult']?['fulfillmentText'] ??
        "Sorry, I didn't get that.";

    client.close();
    return fulfillmentText;
  }
}
