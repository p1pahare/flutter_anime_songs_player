import 'dart:developer';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/democat.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ExploreController extends GetxController with StateMixin<List<DemoCat>> {
  NetworkCalls networkCalls = NetworkCalls();
  int currentPage = 0;

  ScrollController scroll = ScrollController();
  List<DemoCat> cats = [];
  ExploreController() {
    scroll.addListener(() {
      if (scroll.position.maxScrollExtent == scroll.position.pixels) {
        currentPage++;
        bringCats();
      }
    });
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

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    cats.clear();
    super.dispose();
  }
}
