import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:http/http.dart' as http;

class NetworkCalls {
  Future<ApiResponse> getCats({int page = 1}) async {
    try {
      var headers = {
        'x-api-key': 'ef272bbf-4024-4e2b-903e-c617ec7fb8ca',
      };

      var params = {
        'size': 'mid',
        'page': page,
        'limit': '7',
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

  Future<ApiResponse> searchAnimeMain(String title,
      {bool isUrl = false}) async {
    try {
      var request = http.Request(
          'GET',
          Uri.parse(isUrl
              ? title
              : 'https://staging.animethemes.moe/api/anime?include=animethemes.animethemeentries.videos,animethemes.song,images,resources,animethemes.song.artists&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,group&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap,link&fields[image]=facet,link&fields[song]=title&page[size]=15&page[number]=1&q=${percentEncode(title)}'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Anime were retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = response.reasonPhrase ?? 'Something Went Wrong';
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
      var request = http.Request(
          'GET',
          Uri.parse(isUrl
              ? title
              : 'https://staging.animethemes.moe/api/search?fields[search]=anime,animethemes,artists,series,studios&include[anime]=animethemes.animethemeentries.videos,animethemes.song,images,resources&include[animetheme]=animethemeentries.videos,anime.images,song.artists&include[artist]=images,songs&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,group,id&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap,link&fields[image]=facet,link&fields[song]=title&fields[artist]=name,slug,as&fields[series]=name,slug&fields[studio]=name,slug&limit=4&q=${percentEncode(title)}'));
//&filter[has]=song
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Animethemes were retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = response.reasonPhrase ?? 'Something Went Wrong';
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
      var request = http.Request('GET',
          Uri.parse('https://themes.moe/api/anilist/${percentEncode(title)}'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
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
        String message = response.reasonPhrase ?? 'Something Went Wrong';
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
      var request = http.Request('GET',
          Uri.parse('https://themes.moe/api/mal/${percentEncode(title)}'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "MyAnimeListProfile was retrieved successfully",
          "data": jsonDecode(body)
        });
      } else {
        String message = response.reasonPhrase ?? 'Something Went Wrong';
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

  Future<ApiResponse> getMP3VersionOfSong(
      String malId, String themeId, String videoUrl) async {
    try {
      var request = http.Request('POST',
          Uri.parse('https://themes.moe/api/themes/$malId/$themeId/audio'));
      request.body = videoUrl;

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "MP3 Link fetched successfully",
          "data": body
        });
      } else {
        String message = response.reasonPhrase ?? 'Something Went Wrong';
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
