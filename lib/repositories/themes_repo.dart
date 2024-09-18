import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:http/http.dart' as http;

class ThemesRepository {
  Future<ApiResponse> getMP3VersionOfSong(
      String malId, String themeId, String videoUrl) async {
    try {
      final request = http.Request('POST',
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

  Future<ApiResponse> getAnimeFromSlug(String slug) async {
    try {
      final request = http.Request('GET',
          Uri.parse('${Values.baseUrl}/anime/$slug?include=resources,images'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Anime Data fetched successfully",
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

  Future<ApiResponse> getResourcesFromMalIds(List<String> malIds) async {
    String malIdString = '';
    for (int index = 0; index < malIds.length; index++) {
      malIdString += malIds[index];
      if (index != malIds.length - 1) {
        malIdString += ',';
      }
    }
    try {
      final request = http.Request(
          'GET',
          Uri.parse(
              '${Values.baseUrl}/resource?include=anime&filter[external_id]=$malIdString&filter[site]=MyAnimeList'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Anime Data fetched successfully",
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

  Future<ApiResponse> getAnimesFromAnimeSlugs(List<String> animeSlugs) async {
    String animeSlugString = '';
    for (int index = 0; index < animeSlugs.length; index++) {
      animeSlugString += animeSlugs[index];
      if (index != animeSlugs.length - 1) {
        animeSlugString += ',';
      }
    }
    try {
      final request = http.Request(
          'GET',
          Uri.parse(
              '${Values.baseUrl}/anime?include=animethemes.animethemeentries.videos,animethemes.animethemeentries.videos.audio,animethemes.song,images,resources,animethemes.song.artists,studios&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,id&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap,link&fields[image]=facet,link&fields[song]=title&filter[slug]=$animeSlugString&page[size]=15&page[number]=1'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        log(body);
        return ApiResponse.fromJson({
          "status": true,
          "message": "Anime Data fetched successfully",
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

  Future<ApiResponse> searchByAnimeYearSeason(int year, String season) async {
    try {
      final request = http.Request(
          'GET',
          Uri.parse(
              '${Values.baseUrl}/anime?page[size]=50&page[number]=1&filter[season]=$season&filter[year]=$year&sort=random&include=resources,animethemes.animethemeentries.videos,animethemes.animethemeentries.videos.audio,animethemes.song,images'));

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
}
