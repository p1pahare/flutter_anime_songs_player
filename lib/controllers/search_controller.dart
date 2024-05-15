import 'dart:developer';

import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/linksmain.dart';
import 'package:anime_themes_player/models/resources_main.dart';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

enum MediaType { audio, video }

class SearchController extends GetxController {
  NetworkCalls networkCalls = NetworkCalls();
  final TextEditingController search = TextEditingController();
  int searchByValue = 0;
  bool loadingSong = false;
  LinksMain? linksMain;
  RxList<dynamic> listings = RxList.empty();
  RxStatus status = RxStatus.success();
  List<ThemesMalAni> animeList = [];
  late HeadlessInAppWebView headlessWebView;
  late CookieManager cookieManager;
  Map<int, String> searchValuesMap = {
    0: 'Anime Title',
    1: 'Theme Title',
    // 2: 'MyAnimeList Profile',
    // 3: 'Anilist Profile'
  };
  void changesearchByValue(int? newValue) {
    searchByValue = newValue ?? 0;
    update();
  }

  void onClear() async {
    if (search.text.isNotEmpty) {
      search.clear();
    }
    update();
  }

  void onSearch() async {
    Get.focusScope?.unfocus();
    searchListings();
    update();
  }

  void getCookies() async {
    cookieManager = CookieManager.instance();
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri("https://animethemes.moe")),
      onLoadStop: (controller, url) async {
        List<Cookie> cookies = await cookieManager.getCookies(url: url!);
        for (var cookie in cookies) {
          log('Cookie: ${cookie.name}=${cookie.value}');
        }
        await headlessWebView.dispose();
      },
    );
    headlessWebView.run();
  }

  SearchController() {
    scroll.addListener(() async {
      if (scroll.position.maxScrollExtent == scroll.position.pixels) {
        if (!status.isLoadingMore) {
          await fetchMoreEntries();
        }
      }
    });
  }
  int currentIndex = -1;

  ScrollController scroll = ScrollController();

  initalizeLoadingStatus() {}

  Future fetchMoreEntries() async {
    log(linksMain?.toJson().toString() ?? '');
    if (linksMain == null || linksMain?.next == null) return;
    status = RxStatus.loadingMore();
    update();
    final apiResponse = await networkCalls.loadMore(linksMain?.next);
    if (apiResponse.status) {
      linksMain = LinksMain.fromJson(apiResponse.data['links']);

      if (apiResponse.data['anime'] != null) {
        listings.addAll((apiResponse.data['anime'] as List<dynamic>)
            .map((e) => AnimeMain.fromJson(e))
            .toList());
      }
      if (apiResponse.data['animethemes'] != null) {
        listings.addAll((apiResponse.data['animethemes'] as List<dynamic>)
            .map((e) => AnimethemesMain.fromJson(e))
            .toList());
      }
      if (apiResponse.data['resources'] != null) {
        final List<ResourcesMain> resorcesMain =
            (apiResponse.data['resources'] as List<dynamic>)
                .map<ResourcesMain>((e) => ResourcesMain.fromJson(e))
                .toList();

        final ApiResponse apiResponse2 =
            await networkCalls.getAnimesFromAnimeSlugs(resorcesMain
                .where((element) => element.anime.isNotEmpty)
                .map<String>((e) => e.anime[0].slug)
                .toList());

        if (apiResponse2.status) {
          listings.addAll((apiResponse2.data['anime'] as List<dynamic>)
              .map<AnimeMain>((e) => AnimeMain.fromJson(e))
              .toList());
        }
      }
      listings.refresh();

      update();
    }
    status = RxStatus.success();
  }

  Future fetchAnimeLists() async {
    status = RxStatus.loadingMore();

    final List<AnimeMain?> animeMain = await animesFromMalIds(
        animeList.map<String>((e) => "${e.malID}").toList());
    if (animeMain.isNotEmpty) {
      listings.addAll(animeMain);
      listings.refresh();
      update();
    }

    status = RxStatus.success();
  }

  searchListings() async {
    listings.clear();
    status = RxStatus.loading();
    currentIndex = -1;
    ApiResponse apiResponse;
    switch (searchByValue) {
      case 0:
        apiResponse = await networkCalls.searchAnimeMain(search.text);
        if (apiResponse.status) {
          linksMain = LinksMain.fromJson(apiResponse.data['links']);
          listings.addAll((apiResponse.data['anime'] as List<dynamic>)
              .map((e) => AnimeMain.fromJson(e))
              .toList());
          listings.refresh();
        }
        break;
      case 1:
        apiResponse = await networkCalls.searchAnimethemesMain(search.text);
        if (apiResponse.status) {
          linksMain = LinksMain.fromJson(apiResponse.data['links']);
          listings.addAll((apiResponse.data['animethemes'] as List<dynamic>)
              .map((e) => AnimethemesMain.fromJson(e))
              .toList());
          listings.refresh();
        }
        break;
      case 2:
        apiResponse = await networkCalls.searchMyAnimeListProfile(search.text);
        if (apiResponse.status) {
          animeList = (apiResponse.data as List<dynamic>)
              .map((e) => ThemesMalAni.fromJson(e))
              .toList();
          await fetchAnimeLists();
        }
        break;
      default:
        apiResponse = await networkCalls.searchAnilistProfile(search.text);
        if (apiResponse.status) {
          animeList = (apiResponse.data as List<dynamic>)
              .map((e) => ThemesMalAni.fromJson(e))
              .toList();

          await fetchAnimeLists();
        }
    }
    if (apiResponse.status) {
      if (listings.isEmpty) {
        status = RxStatus.empty();
      } else {
        status = RxStatus.success();
      }
    } else {
      status = RxStatus.error(apiResponse.message);
    }
    update();
  }

/* Usage
           ApiResponse apiResponse = await _.webmToMp3(
                              animeMain!.resources.first.externalId.toString(),
                              "${animethemes!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}",
                              animethemeentries!.videos.first.link);
*/
  Future<ApiResponse> webmToMp3(
      String malId, String themeId, String videoUrl) async {
    loadingSong = true;
    update();
    ApiResponse apiResponse =
        await networkCalls.getMP3VersionOfSong(malId, themeId, videoUrl);
    loadingSong = false;
    update();
    return apiResponse;
  }

  Future<AnimeMain?> slugToMalId(String slug) async {
    loadingSong = true;
    update();
    ApiResponse apiResponse = await networkCalls.getAnimeFromSlug(slug);
    loadingSong = false;
    update();
    if (apiResponse.status) {
      return AnimeMain.fromJson(apiResponse.data['anime']);
    }
    return null;
  }

  Future<List<AnimeMain?>> animesFromMalIds(List<String> malIds) async {
    final ApiResponse apiResponse1 =
        await networkCalls.getResourcesFromMalIds(malIds);
    if (apiResponse1.status) {
      linksMain = LinksMain.fromJson(apiResponse1.data['links']);
      final List<ResourcesMain> resorcesMain =
          (apiResponse1.data['resources'] as List<dynamic>)
              .map<ResourcesMain>((e) => ResourcesMain.fromJson(e))
              .toList();

      final ApiResponse apiResponse2 =
          await networkCalls.getAnimesFromAnimeSlugs(resorcesMain
              .where((element) => element.anime.isNotEmpty)
              .map<String>((e) => e.anime[0].slug)
              .toList());

      if (apiResponse2.status) {
        return (apiResponse2.data['anime'] as List<dynamic>)
            .map<AnimeMain>((e) => AnimeMain.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    listings.clear();
    super.dispose();
  }
}
