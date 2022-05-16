import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/democat.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class SearchController extends GetxController with StateMixin<List<DemoCat>> {
  NetworkCalls networkCalls = NetworkCalls();
  final TextEditingController search = TextEditingController();
  int searchByValue = 0;
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
    if (search.text.isNotEmpty) {
      search.clear();
    }
    update();
  }

  bringCats() async {
    change([], status: RxStatus.loading());
    ApiResponse apiResponse = await networkCalls.getCats();
    if (apiResponse.status) {
      List<DemoCat> cats = (apiResponse.data as List<dynamic>)
          .map((e) => DemoCat.fromJson(e))
          .toList();
      if (cats.isEmpty) {
        change(cats, status: RxStatus.empty());
      }
      change(cats, status: RxStatus.success());
    } else {
      change(null, status: RxStatus.error(apiResponse.message));
    }
  }
}
