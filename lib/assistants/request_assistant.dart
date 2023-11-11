import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    try {
      if (response.statusCode == 200) {
        String resData = response.body;
        var decodeResponseData = jsonDecode(resData);
        return decodeResponseData;
      } else {
        return "Error Occurred In Response";
      }
    } catch (e) {
      return "Failed";
    }
  }
}
