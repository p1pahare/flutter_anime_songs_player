import 'dart:developer';

import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/linksmain.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/themes_repo.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  AnimeThemeRepository animeThemesRepository = AnimeThemeRepository();
  ThemesRepository themesRepository = ThemesRepository();
  int currentPage = 0;
  ScrollController scroll = ScrollController();
  RxList<dynamic> listings = RxList.empty();
  RxStatus status = RxStatus.success();
  LinksMain? linksMain;
  int seasonValue = (DateTime.now().month - 1) ~/ 3;
  Map<int, String> seasonValuesMap = {
    0: 'Winter',
    1: 'Spring',
    2: 'Summer',
    3: 'Fall'
  };
  int yearValue = DateTime.now().year - 1963;
  Map<int, int> yearValuesMap = <int, int>{
    for (int i = 1963; i <= DateTime.now().year; i++) i - 1963: i
  };

  void changeseasonValue(int? newValue) {
    seasonValue = newValue ?? 0;
    update();
    searchListings();
  }

  void changeyearValue(int? newValue) {
    yearValue = newValue ?? 0;
    update();
    searchListings();
  }

  ExploreController() {
    scroll.addListener(() async {
      if (scroll.position.maxScrollExtent == scroll.position.pixels) {
        if (!status.isLoadingMore) {
          await fetchMoreEntries();
        }
      }
    });
  }

  searchListings() async {
    listings.clear();
    listings.refresh();
    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update();
    ApiResponse apiResponse;
    apiResponse = await themesRepository.searchByAnimeYearSeason(
        yearValuesMap[yearValue] ?? DateTime.now().year,
        seasonValuesMap[seasonValue]!.toLowerCase());
    if (apiResponse.status) {
      linksMain = LinksMain.fromJson(apiResponse.data['links']);
      listings.value = [
        ...listings,
        ...(apiResponse.data["anime"] ?? [])
            .map((e) => Anime.fromJson(e))
            .toList()
      ];
    }

    if (apiResponse.status) {
      if (listings.isEmpty) {
        listings.refresh();
        status = RxStatus.empty();
        update();
      } else {
        listings.refresh();
        status = RxStatus.success();
        update();
      }
    } else {
      status = RxStatus.error(apiResponse.message);
      listings.clear();
      listings.refresh();
      update();
    }
  }

  Future fetchMoreEntries() async {
    log(linksMain?.toJson().toString() ?? '');
    if (linksMain == null || linksMain?.next == null) return;
    status = RxStatus.loadingMore();
    update();
    final apiResponse = await animeThemesRepository.loadMore(linksMain?.next);
    if (apiResponse.status) {
      linksMain = LinksMain.fromJson(apiResponse.data['links']);

      if (apiResponse.data['anime'] != null) {
        listings.addAll((apiResponse.data['anime'] as List<dynamic>)
            .map((e) => Anime.fromJson(e))
            .toList());
      }
      listings.refresh();
      status = RxStatus.success();
      update();
    } else {
      status = RxStatus.error(Values.loadMoreFailed);
      update();
    }
  }

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    listings.clear();
    themesRepository.dispose();
    animeThemesRepository.dispose();
    super.dispose();
  }
}
