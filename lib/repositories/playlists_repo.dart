import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistRepo extends GetConnect {
  final box = GetStorage();
  String _currentToken = "";
  String get currentToken => _currentToken;

  set currentToken(String value) {
    if (value.isNotEmpty) {
      _currentToken = value;
      box.write("LOGIN_TOKEN", value);
    }
  }

  PlaylistRepo() {
    currentToken = box.read("LOGIN_TOKEN") ?? "";
  }
  final headerCommon = {
    'Origin': 'https://animethemes.moe',
    'Referer': ' https://animethemes.moe/',
    'X-Requested-With': 'XMLHttpRequest',
  };
  Future saveCookies(Response response) async {
    final cookies = response.headers?['set-cookie'];
    if (cookies != null) {
      String roastedCookie = "";
      final cookieParts = cookies.split(',');
      for (int save = 1; save <= cookieParts.length; save++) {
        roastedCookie += cookieParts[save - 1].split(';').first;
        if (save != cookieParts.length) {
          roastedCookie += ';';
        }
      }
      await box.write('cookies', roastedCookie);
      log(roastedCookie);
    }
  }

  String? getStoredCookies() {
    return box.read('cookies');
  }

  Future<void> getCookie() async {
    Response response =
        await get('https://api.animethemes.moe/', headers: headerCommon);
    response = await get('https://api.animethemes.moe/', headers: headerCommon);
    saveCookies(response);
  }

  String extractCSRFFromCookies(String? cookies) {
    final packetBroken = cookies?.split(';') ?? [];
    for (String x in packetBroken) {
      final cookieBroken = x.split('=');
      if (cookieBroken.length == 2 && cookieBroken[0] == "XSRF-TOKEN") {
        return Uri.decodeFull(cookieBroken[1]);
      }
    }
    return '';
  }

  Future<void> getToken() async {
    String? cookies = getStoredCookies();
    final response = await get(
      'https://api.animethemes.moe/sanctum/csrf-cookie',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        "X-XSRF-TOKEN": extractCSRFFromCookies(cookies)
      },
    );

    if (response.isOk) {
      await saveCookies(response);
      currentToken = extractCSRFFromCookies(getStoredCookies());
      log('Second Response: ${response.body} $currentToken');
    } else {
      log('Failed: ${response.statusText}');
    }
  }

  Future<void> loginUser() async {
    String? cookies = getStoredCookies();
    final response = await post(
      'https://api.animethemes.moe/auth/login',
      '{"email":"p1pahare@gmail.com","password":"@Chalbechal55","remember":true}',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        "X-XSRF-TOKEN": currentToken,
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-site',
        'TE': 'trailers'
      },
    );

    if (response.isOk) {
      saveCookies(response);
      log('Third Response: ${response.body}');
    } else {
      log('Failed: ${response.bodyString} $currentToken ${extractCSRFFromCookies(cookies)}');
    }
  }

  Future<void> getUserDetails() async {
    String? cookies = getStoredCookies();
    final response = await get(
      'https://api.animethemes.moe/me',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        "X-XSRF-TOKEN": currentToken
      },
    );

    if (response.isOk) {
      saveCookies(response);
      log('Fourth Response: ${response.body}');
    } else {
      log('Failed: ${response.statusText}');
    }
  }
}
