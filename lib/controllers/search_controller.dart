import 'dart:developer';

import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/democat.dart';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  NetworkCalls networkCalls = NetworkCalls();
  final TextEditingController search = TextEditingController();
  int searchByValue = 0;
  bool loadingSong = false;
  List<DemoCat> cats = [];
  RxList<dynamic> listings = RxList.empty();
  RxStatus status = RxStatus.loadingMore();
  List<ThemesMalAni> animeList = [];
  Map<int, String> searchValuesMap = {
    0: 'Anime Title',
    1: 'Theme Title',
    2: 'MyAnimeList Profile',
    3: 'Anilist Profile'
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

  SearchController() {
    scroll.addListener(() async {
      if (scroll.position.maxScrollExtent == scroll.position.pixels) {
        await fetchAnimeLists();
      }
    });
  }
  int currentIndex = 0;

  ScrollController scroll = ScrollController();

  initalizeLoadingStatus() {}

  bringCats({bool reload = false}) async {
    if (reload) cats.clear();
    update();
    ApiResponse apiResponse = await networkCalls.getCats(page: currentIndex);
    if (apiResponse.status) {
      cats = [
        ...cats,
        ...(apiResponse.data as List<dynamic>)
            .map((e) => DemoCat.fromJson(e))
            .toList()
      ];
      if (cats.isEmpty) {
        update();
      }

      update();
    } else {
      update();
    }
  }

  Future fetchAnimeLists() async {
    for (int i = 0; i < 5; i++) {
      currentIndex++;
      if (animeList.length > currentIndex) {
        final AnimeMain? animeMain =
            await titleToMalId(animeList[currentIndex].name);
        if (animeMain != null) {
          listings.add(animeMain);
          listings.refresh();
          update();
        }
      }
    }
  }

  searchListings() async {
    listings.clear();
    status = RxStatus.loading();
    currentIndex = 0;
    ApiResponse apiResponse;
    switch (searchByValue) {
      case 0:
        apiResponse = await networkCalls.searchAnimeMain(search.text);
        if (apiResponse.status) {
          listings.addAll((apiResponse.data['anime'] as List<dynamic>)
              .map((e) => AnimeMain.fromJson(e))
              .toList());
          listings.refresh();
        }
        break;
      case 1:
        apiResponse = await networkCalls.searchAnimethemesMain(search.text);
        if (apiResponse.status) {
          listings.addAll(
              (apiResponse.data['search']['animethemes'] as List<dynamic>)
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

  Future<AnimeMain?> titleToMalId(String title) async {
    ApiResponse apiResponse = await networkCalls.getAnimeFromTitle(title);

    if (apiResponse.status) {
      return AnimeMain.fromJson(apiResponse.data['anime'][0]);
    }
    return null;
  }

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    cats.clear();
    listings.clear();
    super.dispose();
  }
}
