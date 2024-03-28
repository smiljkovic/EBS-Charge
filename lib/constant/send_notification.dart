import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:smiljkovic/constant/constant.dart';

class SendNotification {
  static sendOneNotification({required String token, required String title, required String body, required Map<String, dynamic> payload}) async {
    http.Response response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constant.serverKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': payload,
          'to': token
        },
      ),
    );
    log(response.body);
  }
}
