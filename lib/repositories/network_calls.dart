import 'dart:convert';
import 'dart:developer';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:http/http.dart' as http;

class NetworkCalls {
  Future<ApiResponse> getCats() async {
    var headers = {
      'x-api-key': 'ef272bbf-4024-4e2b-903e-c617ec7fb8ca',
    };

    var params = {
      'size': 'mid',
      'limit': '100',
    };
    var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

    var url = Uri.parse('https://api.thecatapi.com/v1/images/search?$query');
    var res = await http.get(url, headers: headers);
    if (res.statusCode != 200) {
      return ApiResponse(status: false, message: 'Failed to Load Cats');
    }
    log(res.body);
    return ApiResponse.fromJson({
      "status": true,
      "message": "Cats were called successfully",
      "data": jsonDecode(res.body)
    });
  }
}
