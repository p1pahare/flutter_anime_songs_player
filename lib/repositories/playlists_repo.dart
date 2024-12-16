import 'dart:developer';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/utilities/values.dart';
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
    'Origin': Values.siteUrl,
    'Referer': ' ${Values.siteUrl}/',
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
    Response response = await get('${Values.baseUrl}/', headers: headerCommon);
    response = await get('${Values.baseUrl}/', headers: headerCommon);
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
      '${Values.baseUrl}/sanctum/csrf-cookie',
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

  Future<ApiResponse> loginUser({
    required String email,
    required String password,
    required bool remember,
  }) async {
    String? cookies = getStoredCookies();
    final response = await post(
      '${Values.baseUrl}/auth/login',
      '{"email":"$email","password":"$password","remember":$remember}',
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
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? "",
        data: response.body,
      );
    } else {
      log('Failed: ${response.bodyString} $currentToken ${extractCSRFFromCookies(cookies)}');
      return ApiResponse(
        status: false,
        message: response.body?['message'] ?? response.statusText ?? "",
        data: response.body,
      );
    }
  }

  Future<ApiResponse> registerUser({
    required String userName,
    required String email,
    required String password,
    required String cPassword,
    required bool terms,
  }) async {
    String? cookies = getStoredCookies();
    final response = await post(
      '${Values.baseUrl}/auth/register',
      '{"name":"$userName","email":"$email","password":"$password","password_confirmation":"$cPassword","terms":$terms}',
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
      log('Register Response: ${response.body}');
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? "",
        data: response.body,
      );
    } else {
      log('Failed: ${response.bodyString} $currentToken ${extractCSRFFromCookies(cookies)}');
      return ApiResponse(
        status: false,
        message: response.body?['message'] ?? response.statusText ?? "",
        data: response.body,
      );
    }
  }

  Future<ApiResponse> forgotPassword({
    required String email,
  }) async {
    String? cookies = getStoredCookies();
    final response = await post(
      '${Values.baseUrl}/auth/forgot-password',
      '{"email":"$email"}',
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
      log('Register Response: ${response.body}');
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? "",
        data: response.body,
      );
    } else {
      log('Failed: ${response.bodyString} $currentToken ${extractCSRFFromCookies(cookies)}');
      return ApiResponse(
        status: false,
        message: response.body?['message'] ?? response.statusText ?? "",
        data: response.body,
      );
    }
  }

  Future<ApiResponse> getUserDetails() async {
    String? cookies = getStoredCookies();
    final response = await get(
      '${Values.baseUrl}/me',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        "X-XSRF-TOKEN": currentToken
      },
    );

    if (response.status.connectionError) {
      log('No internet connection');
      return ApiResponse(
        status: false,
        message: "No internet connection",
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      log('Fourth Response: ${response.body}');
      return ApiResponse(
        status: true,
        message: "User is already logged in",
        data: response.bodyString,
      );
    } else {
      log('Failed: ${response.statusText} ${response.bodyString}');
      return ApiResponse(
        status: false,
        message: "User is not logged in",
        data: response.body,
      );
    }
  }
}
