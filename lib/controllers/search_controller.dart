import 'dart:developer';

import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/democat.dart';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController with StateMixin<List<dynamic>> {
  NetworkCalls networkCalls = NetworkCalls();
  final TextEditingController search = TextEditingController();
  int searchByValue = 0;
  bool loadingSong = false;
  List<DemoCat> cats = [];
  List<dynamic> listings = [];
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
    scroll.addListener(() {
      if (scroll.position.maxScrollExtent == scroll.position.pixels) {
        currentPage++;
        // searchListings(reload: true);
      }
    });
  }
  int currentPage = 0;

  ScrollController scroll = ScrollController();

  initalizeLoadingStatus() {
    change(cats, status: RxStatus.empty());
  }

  bringCats({bool reload = false}) async {
    if (reload) cats.clear();
    change(cats,
        status: cats.isEmpty ? RxStatus.loading() : RxStatus.loadingMore());
    ApiResponse apiResponse = await networkCalls.getCats(page: currentPage);
    if (apiResponse.status) {
      cats = [
        ...cats,
        ...(apiResponse.data as List<dynamic>)
            .map((e) => DemoCat.fromJson(e))
            .toList()
      ];
      if (cats.isEmpty) {
        change(cats, status: RxStatus.empty());
      }

      change(cats, status: RxStatus.success());
    } else {
      change(null, status: RxStatus.error(apiResponse.message));
    }
  }

  searchListings() async {
    listings.clear();
    change(listings,
        status: listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore());
    ApiResponse apiResponse;
    switch (searchByValue) {
      case 0:
        apiResponse = await networkCalls.searchAnimeMain(search.text);
        if (apiResponse.status) {
          listings = [
            ...listings,
            ...(apiResponse.data['anime'] as List<dynamic>)
                .map((e) => AnimeMain.fromJson(e))
                .toList()
          ];
        }
        break;
      case 1:
        apiResponse = await networkCalls.searchAnimethemesMain(search.text);
        if (apiResponse.status) {
          listings = [
            ...listings,
            ...(apiResponse.data['search']['animethemes'] as List<dynamic>)
                .map((e) => AnimethemesMain.fromJson(e))
                .toList()
          ];
        }
        break;
      case 2:
        apiResponse = await networkCalls.searchMyAnimeListProfile(search.text);
        if (apiResponse.status) {
          listings = [
            ...listings,
            ...(apiResponse.data as List<dynamic>)
                .map((e) => ThemesMalAni.fromJson(e))
                .toList()
          ];
        }
        break;
      default:
        apiResponse = await networkCalls.searchAnilistProfile(search.text);
        if (apiResponse.status) {
          listings = [
            ...listings,
            ...(apiResponse.data as List<dynamic>)
                .map((e) => ThemesMalAni.fromJson(e))
                .toList()
          ];
        }
    }
    if (apiResponse.status) {
      if (listings.isEmpty) {
        change(cats, status: RxStatus.empty());
      } else {
        change(listings, status: RxStatus.success());
      }
    } else {
      change(null, status: RxStatus.error(apiResponse.message));
    }
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

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    cats.clear();
    listings.clear();
    super.dispose();
  }
}
