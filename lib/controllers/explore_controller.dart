import 'dart:developer';

import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ExploreController extends GetxController
    with StateMixin<List<AnimeMain>> {
  NetworkCalls networkCalls = NetworkCalls();
  int currentPage = 0;
  ScrollController scroll = ScrollController();
  bool loadingSong = false;
  List<AnimeMain> listings = [];
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
    scroll.addListener(() {
      if (scroll.position.maxScrollExtent == scroll.position.pixels) {
        currentPage++;
      }
    });
  }

  searchListings() async {
    listings.clear();
    change(listings,
        status: listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore());
    ApiResponse apiResponse;
    apiResponse = await networkCalls.searchByAnimeYearSeason(
        yearValuesMap[yearValue] ?? DateTime.now().year,
        seasonValuesMap[seasonValue]!.toLowerCase());
    if (apiResponse.status) {
      listings = [
        ...listings,
        ...(apiResponse.data["anime"] ?? [])
            .map((e) => AnimeMain.fromJson(e))
            .toList()
      ];
    }

    if (apiResponse.status) {
      if (listings.isEmpty) {
        change(listings, status: RxStatus.empty());
      } else {
        change(listings, status: RxStatus.success());
      }
    } else {
      change(null, status: RxStatus.error(apiResponse.message));
    }
  }

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    super.dispose();
  }
}
