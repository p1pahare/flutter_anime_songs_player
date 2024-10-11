import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:get/get.dart';

class AnimeThemeRepository {
  GetConnect conn = GetConnect();
  Future<ApiResponse> searchAnimeMain(String title,
      {bool isUrl = false}) async {
    try {
      final response = await conn.get(isUrl
          ? title
          : '${Values.baseUrl}/anime?include=animethemes.animethemeentries.videos,animethemes.animethemeentries.videos.audio,animethemes.song,images,resources,animethemes.song.artists,studios&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,id&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap,link&fields[image]=facet,link&fields[song]=title&page[size]=15&page[number]=1&q=${percentEncode(title)}');

      String body = response.bodyString ?? 'Something Went Wrong';
      if (response.isOk) {
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Anime were retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = body;
        log(message);
        return ApiResponse.fromJson({"status": false, "message": message});
      }
    } catch (e) {
      if (e is SocketException) {
        return ApiResponse(
            status: false,
            message:
                "Network Problem Occurred. Kindly check your internet connection.");
      } else {
        return ApiResponse(status: false, message: e.toString());
      }
    }
  }

  Future<ApiResponse> searchAnimethemesMain(String title,
      {bool isUrl = false}) async {
    try {
      final response = await conn.get(isUrl
          ? title
          : '${Values.baseUrl}/animetheme?include=animethemeentries.videos,anime.images,song.artists&fields[anime]=name,slug,year,season&fields[animetheme]=id,type,sequence,slug&fields[animethemeentry]=version&fields[video]=tags,link,filename&fields[image]=facet,link&fields[song]=title&fields[artist]=name,slug&filter[has]=song&page[size]=15&page[number]=1&q=${percentEncode(title)}');
//&filter[has]=song
      String body = response.bodyString ?? 'Something Went Wrong';

      if (response.isOk) {
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Animethemes were retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = body;
        log(message);
        return ApiResponse.fromJson({"status": false, "message": message});
      }
    } catch (e) {
      if (e is SocketException) {
        return ApiResponse(
            status: false,
            message:
                "Network Problem Occurred. Kindly check your internet connection.");
      } else {
        return ApiResponse(status: false, message: e.toString());
      }
    }
  }

  Future<ApiResponse> searchAnilistProfile(String title) async {
    try {
      final response = await conn
          .get('https://themes.moe/api/anilist/${percentEncode(title)}');

      String body = response.bodyString ?? 'Something Went Wrong';

      if (response.isOk) {
        log(body);
        if (body.length < 3) {
          return ApiResponse.fromJson(
              {"status": false, "message": "Anilist Profile not Found"});
        }
        return ApiResponse.fromJson({
          "status": true,
          "message": "Anilist profile was retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = body;
        log(message);
        return ApiResponse.fromJson({"status": false, "message": message});
      }
    } catch (e) {
      if (e is SocketException) {
        return ApiResponse(
            status: false,
            message:
                "Network Problem Occurred. Kindly check your internet connection.");
      } else {
        return ApiResponse(status: false, message: e.toString());
      }
    }
  }

  Future<ApiResponse> loadMore(String? url) async {
    try {
      final response = await conn.get(url ?? 'https://example.com');

      String body = response.bodyString ?? 'Something Went Wrong';

      if (response.isOk) {
        log(body);
        if (body.length < 3) {
          return ApiResponse.fromJson(
              {"status": false, "message": "Data not Found"});
        }
        return ApiResponse.fromJson({
          "status": true,
          "message": "More Entries retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = body;
        log(message);
        return ApiResponse.fromJson({"status": false, "message": message});
      }
    } catch (e) {
      if (e is SocketException) {
        return ApiResponse(
            status: false,
            message:
                "Network Problem Occurred. Kindly check your internet connection.");
      } else {
        return ApiResponse(status: false, message: e.toString());
      }
    }
  }

  Future<ApiResponse> searchMyAnimeListProfile(String title) async {
    try {
      final response =
          await conn.get('https://themes.moe/api/mal/${percentEncode(title)}');

      String body = response.bodyString ?? 'Something Went Wrong';

      if (response.isOk) {
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "MyAnimeListProfile was retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = body;
        log(message);
        return ApiResponse.fromJson({"status": false, "message": message});
      }
    } catch (e) {
      if (e is SocketException) {
        return ApiResponse(
            status: false,
            message:
                "Network Problem Occurred. Kindly check your internet connection.");
      } else {
        return ApiResponse(status: false, message: e.toString());
      }
    }
  }

  Future<ApiResponse> loadAnimetheme(int themeId) async {
    try {
      final response = await conn.get(
          '${Values.baseUrl}/animetheme/$themeId?include=animethemeentries.videos,animethemeentries.videos.audio,anime.images,song.artists');
      //,animethemeentries.videos.audio
      String body = response.bodyString ?? 'Something Went Wrong';

      if (response.isOk) {
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Anime were retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = body;
        log(message);
        return ApiResponse.fromJson({"status": false, "message": message});
      }
    } catch (e) {
      if (e is SocketException) {
        return ApiResponse(
            status: false,
            message:
                "Network Problem Occurred. Kindly check your internet connection.");
      } else {
        return ApiResponse(status: false, message: e.toString());
      }
    }
  }
}
