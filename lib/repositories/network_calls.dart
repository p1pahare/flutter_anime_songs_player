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
      final request = http.Request(
          'GET',
          Uri.parse(isUrl
              ? title
              : 'https://staging.animethemes.moe/api/anime?include=animethemes.animethemeentries.videos,animethemes.song,images,resources,animethemes.song.artists,studios&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,group,id&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap,link&fields[image]=facet,link&fields[song]=title&page[size]=15&page[number]=1&q=${percentEncode(title)}'));

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
      final request = http.Request(
          'GET',
          Uri.parse(isUrl
              ? title
              : 'https://staging.animethemes.moe/api/animetheme?include=animethemeentries.videos,anime.images,song.artists&fields[anime]=name,slug,year,season&fields[animetheme]=id,type,sequence,slug,group&fields[animethemeentry]=version&fields[video]=tags,link&fields[image]=facet,link&fields[song]=title&fields[artist]=name,slug,as&filter[has]=song&page[size]=15&page[number]=1&q=${percentEncode(title)}'));
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
      final request = http.Request('GET',
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

  Future<ApiResponse> loadMore(String? url) async {
    try {
      final request =
          http.Request('GET', Uri.parse(url ?? 'https://example.com'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
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
      final request = http.Request('GET',
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
      final request = http.Request(
          'GET',
          Uri.parse(
              'https://staging.animethemes.moe/api/anime/$slug?include=resources,images'));

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
              'https://staging.animethemes.moe/api/resource?include=anime&filter[external_id]=$malIdString&filter[site]=MyAnimeList'));

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
              'https://staging.animethemes.moe/api/anime?include=animethemes.animethemeentries.videos,animethemes.song,images,resources,animethemes.song.artists,studios&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,group,id&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap,link&fields[image]=facet,link&fields[song]=title&filter[slug]=$animeSlugString&page[size]=15&page[number]=1'));

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

  Future<ApiResponse> searchByAnimeyear(int year) async {
    try {
      final request = http.Request(
          'GET',
          Uri.parse(
              'https://staging.animethemes.moe/api/animeyear/$year?include=animethemes.animethemeentries.videos,animethemes.song,images,resources,animethemes.song.artists,studios&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,group,id&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap,link&fields[image]=facet,link&fields[song]=title'));

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

  Future<ApiResponse> loadAnimetheme(int themeId) async {
    try {
      final request = http.Request(
          'GET',
          Uri.parse(
              'https://staging.animethemes.moe/api/animetheme/$themeId?include=animethemeentries.videos,anime.images,song.artists'));

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
