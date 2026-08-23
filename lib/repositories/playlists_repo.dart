import 'dart:developer';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistsRepo extends GetConnect {
  final box = GetStorage();
  String _currentToken = "";
  String get currentToken => _currentToken;

  set currentToken(String value) {
    if (value.isNotEmpty) {
      _currentToken = value;
      box.write("LOGIN_TOKEN", value);
    }
  }

  PlaylistsRepo() {
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

  Future<ApiResponse> getMyPlaylists() async {
    String? cookies = getStoredCookies();
    final response = await get(
      '${Values.baseUrl}/me/playlist/',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': currentToken,
        'Accept': 'application/json, text/plain, */*',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }

  Future<ApiResponse> getPlaylistSongs({
    required String playlistId,
    String include = 'video,video.audio',
  }) async {
    String? cookies = getStoredCookies();
    final response = await get(
      '${Values.baseUrl}/playlist/$playlistId/track?include=${Uri.encodeQueryComponent(include)}',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': currentToken,
        'Accept': 'application/json, text/plain, */*',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }

  Future<ApiResponse> getPlaylistData({
    required String playlistId,
    String include =
        'video.audio,animethemeentry.animetheme.anime.images,animethemeentry.animetheme.song.artists',
    int pageSize = 50,
    int pageNumber = 1,
  }) async {
    String? cookies = getStoredCookies();
    final query = Uri(queryParameters: {
      'include': include,
      'page[size]': '$pageSize',
      'page[number]': '$pageNumber',
    }).query;
    final response = await get(
      '${Values.baseUrl}/playlist/$playlistId/track?$query',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': currentToken,
        'Accept': 'application/json, text/plain, */*',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }

  Future<ApiResponse> checkTrackOnPlaylist({
    required int videoId,
    String fields = 'id,name,visibility,tracks_count',
    String include = 'tracks',
    int pageSize = 25,
  }) async {
    String? cookies = getStoredCookies();
    final query = Uri(queryParameters: {
      'fields[playlist]': fields,
      'filter[track][video_id]': '$videoId',
      'include': include,
      'page[size]': '$pageSize',
    }).query;
    final response = await get(
      '${Values.baseUrl}/me/playlist?$query',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': currentToken,
        'Accept': 'application/json, text/plain, */*',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }

  Future<ApiResponse> addTrackToPlaylist({
    required String playlistId,
    required int videoId,
    required int entryId,
  }) async {
    String? cookies = getStoredCookies();
    final xsrfToken = extractCSRFFromCookies(cookies);
    final response = await post(
      '${Values.baseUrl}/playlist/$playlistId/track',
      {
        'video_id': videoId,
        'entry_id': entryId,
      },
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': xsrfToken.isNotEmpty ? xsrfToken : currentToken,
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }

  Future<ApiResponse> deleteTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    String? cookies = getStoredCookies();
    final xsrfToken = extractCSRFFromCookies(cookies);
    final response = await delete(
      '${Values.baseUrl}/playlist/$playlistId/track/$trackId',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': xsrfToken.isNotEmpty ? xsrfToken : currentToken,
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }

  Future<ApiResponse> createPlaylist({
    required String name,
    required String visibility,
  }) async {
    String? cookies = getStoredCookies();
    final xsrfToken = extractCSRFFromCookies(cookies);
    final response = await post(
      '${Values.baseUrl}/playlist',
      {
        'name': name,
        'visibility': visibility,
      },
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': xsrfToken.isNotEmpty ? xsrfToken : currentToken,
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }

  Future<ApiResponse> deletePlaylist({
    required String playlistId,
  }) async {
    String? cookies = getStoredCookies();
    final xsrfToken = extractCSRFFromCookies(cookies);
    final response = await delete(
      '${Values.baseUrl}/playlist/$playlistId',
      headers: {
        if (cookies != null) 'Cookie': cookies,
        ...headerCommon,
        'X-XSRF-TOKEN': xsrfToken.isNotEmpty ? xsrfToken : currentToken,
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      },
    );

    if (response.status.connectionError) {
      return ApiResponse(
        status: false,
        message: 'No internet connection',
        data: false,
      );
    } else if (response.isOk) {
      saveCookies(response);
      return ApiResponse(
        status: true,
        message: response.body?['message'] ?? response.statusText ?? '',
        data: response.body,
      );
    }
    return ApiResponse(
      status: false,
      message: response.body?['message'] ?? response.statusText ?? '',
      data: response.body,
    );
  }
}
