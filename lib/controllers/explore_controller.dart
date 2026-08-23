import 'dart:developer';
import 'dart:convert';

import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/linksmain.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/themes_repo.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ExploreController extends GetxController {
  static const String _exploreCachePrefix = 'cache_explore_';
  AnimeThemeRepository animeThemesRepository = AnimeThemeRepository();
  ThemesRepository themesRepository = ThemesRepository();
  GetStorage box = GetStorage();
  int currentPage = 0;
  ScrollController scroll = ScrollController();
  RxList<dynamic> listings = RxList.empty();
  RxStatus status = RxStatus.success();
  LinksMain? linksMain;
  final Set<String> _loadingMoreKeys = {};
  String? _loadedCacheKey;
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

  String get currentCacheKey =>
      '$_exploreCachePrefix${yearValuesMap[yearValue] ?? DateTime.now().year}_${seasonValuesMap[seasonValue]?.toLowerCase() ?? ''}';

  Map<String, dynamic>? _readCachedMap(String key) {
    final cached = box.read(key);
    if (cached is Map) {
      return Map<String, dynamic>.from(jsonDecode(jsonEncode(cached)));
    }
    return null;
  }

  bool hydrateExploreFromCache() {
    final cacheKey = currentCacheKey;
    if (listings.isNotEmpty && _loadedCacheKey == cacheKey) return true;
    final cached = _readCachedMap(cacheKey);
    if (cached == null) return false;
    linksMain = LinksMain.fromJson(cached['links'] ?? {});
    listings.value = [
      ...(cached["anime"] ?? []).map((e) => Anime.fromJson(e)).toList()
    ];
    _loadedCacheKey = cacheKey;
    status = listings.isEmpty ? RxStatus.empty() : RxStatus.success();
    listings.refresh();
    update();
    return listings.isNotEmpty;
  }

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

  searchListings({bool forceRefresh = false}) async {
    final cacheKey = currentCacheKey;
    final hadVisibleListings =
        listings.isNotEmpty && _loadedCacheKey == cacheKey;
    if (!forceRefresh && hydrateExploreFromCache()) return;
    if (!hadVisibleListings) {
      listings.clear();
      listings.refresh();
    }
    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update();
    ApiResponse apiResponse;
    apiResponse = await themesRepository.searchByAnimeYearSeason(
        yearValuesMap[yearValue] ?? DateTime.now().year,
        seasonValuesMap[seasonValue]!.toLowerCase());
    if (apiResponse.status) {
      await box.write(cacheKey, apiResponse.data);
      linksMain = LinksMain.fromJson(apiResponse.data['links']);
      listings.value = [
        ...(apiResponse.data["anime"] ?? [])
            .map((e) => Anime.fromJson(e))
            .toList()
      ];
      _loadedCacheKey = cacheKey;
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
      if (listings.isEmpty) {
        listings.clear();
        listings.refresh();
      }
      update();
    }
  }

  Future fetchMoreEntries() async {
    final cacheKey = currentCacheKey;
    log(linksMain?.toJson().toString() ?? '');
    if (linksMain == null ||
        linksMain?.next == null ||
        _loadingMoreKeys.contains(cacheKey)) {
      return;
    }
    _loadingMoreKeys.add(cacheKey);
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
      await box.write(cacheKey, {
        'anime': listings.map((e) => (e as Anime).toJson()).toList(),
        'links': linksMain?.toJson(),
      });
      listings.refresh();
      status = RxStatus.success();
      update();
    } else {
      status = RxStatus.error(Values.loadMoreFailed);
      update();
    }
    _loadingMoreKeys.remove(cacheKey);
  }

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    listings.clear();
    _loadingMoreKeys.clear();
    themesRepository.dispose();
    animeThemesRepository.dispose();
    super.dispose();
  }
}
