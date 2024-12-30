import 'dart:developer';

import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/animethemes.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/linksmain.dart';
import 'package:anime_themes_player/models/resources.dart';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/themes_repo.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MediaType { audio, video }

class SearchController extends GetxController {
  AnimeThemeRepository animeThemesRepository = AnimeThemeRepository();
  ThemesRepository themesRepository = ThemesRepository();
  final TextEditingController search = TextEditingController();
  int searchByValue = 0;
  bool loadingSong = false;
  LinksMain? linksMain;
  RxList<dynamic> listings = RxList.empty();
  RxStatus status = RxStatus.success();
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
    final apiResponse = await animeThemesRepository.loadMore(linksMain?.next);
    if (apiResponse.status) {
      linksMain = LinksMain.fromJson(apiResponse.data['links']);

      if (apiResponse.data['anime'] != null) {
        listings.addAll((apiResponse.data['anime'] as List<dynamic>)
            .map((e) => Anime.fromJson(e))
            .toList());
      }
      if (apiResponse.data['animethemes'] != null) {
        listings.addAll((apiResponse.data['animethemes'] as List<dynamic>)
            .map((e) => Animethemes.fromJson(e))
            .toList());
      }
      if (apiResponse.data['resources'] != null) {
        final List<Resources> resorcesMain =
            (apiResponse.data['resources'] as List<dynamic>)
                .map<Resources>((e) => Resources.fromJson(e))
                .toList();

        final ApiResponse apiResponse2 =
            await themesRepository.getAnimesFromAnimeSlugs(resorcesMain
                .where((element) => element.anime.isNotEmpty)
                .map<String>((e) => e.anime[0].slug)
                .toList());

        if (apiResponse2.status) {
          listings.addAll((apiResponse2.data['anime'] as List<dynamic>)
              .map<Anime>((e) => Anime.fromJson(e))
              .toList());
        }
      }
      listings.refresh();
      status = RxStatus.success();
      update();
    } else {
      status = RxStatus.error(Values.loadMoreFailed);
      update();
    }
  }

  Future fetchAnimeLists() async {
    status = RxStatus.loadingMore();

    final List<Anime?> animeMain = await animesFromMalIds(
        animeList.map<String>((e) => "${e.malID}").toSet().toList());
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
        apiResponse = await animeThemesRepository.searchAnimeMain(search.text);
        if (apiResponse.status) {
          linksMain = LinksMain.fromJson(apiResponse.data['links']);
          listings.addAll((apiResponse.data['anime'] as List<dynamic>)
              .map((e) => Anime.fromJson(e))
              .toList());
          listings.refresh();
        }
        break;
      case 1:
        apiResponse =
            await animeThemesRepository.searchAnimethemesMain(search.text);
        if (apiResponse.status) {
          linksMain = LinksMain.fromJson(apiResponse.data['links']);
          listings.addAll((apiResponse.data['animethemes'] as List<dynamic>)
              .map((e) => Animethemes.fromJson(e))
              .toList());
          listings.refresh();
        }
        break;
      case 2:
        apiResponse =
            await animeThemesRepository.searchMyAnimeListProfile(search.text);
        if (apiResponse.status) {
          animeList = (apiResponse.data as List<dynamic>)
              .map((e) => ThemesMalAni.fromJson(e))
              .toList();
          await fetchAnimeLists();
        }
        break;
      default:
        apiResponse =
            await animeThemesRepository.searchAnilistProfile(search.text);
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
        await themesRepository.getMP3VersionOfSong(malId, themeId, videoUrl);
    loadingSong = false;
    update();
    return apiResponse;
  }

  Future<Anime?> slugToMalId(String slug) async {
    loadingSong = true;
    update();
    ApiResponse apiResponse = await themesRepository.getAnimeFromSlug(slug);
    loadingSong = false;
    update();
    if (apiResponse.status) {
      return Anime.fromJson(apiResponse.data['anime']);
    }
    return null;
  }

  Future<List<Anime?>> animesFromMalIds(List<String> malIds) async {
    final ApiResponse apiResponse1 =
        await themesRepository.getResourcesFromMalIds(malIds);
    if (apiResponse1.status) {
      linksMain = LinksMain.fromJson(apiResponse1.data['links']);
      final List<Resources> resorcesMain =
          (apiResponse1.data['resources'] as List<dynamic>)
              .map<Resources>((e) => Resources.fromJson(e))
              .toList();

      final ApiResponse apiResponse2 =
          await themesRepository.getAnimesFromAnimeSlugs(resorcesMain
              .where((element) => element.anime.isNotEmpty)
              .map<String>((e) => e.anime[0].slug)
              .toList());

      if (apiResponse2.status) {
        return (apiResponse2.data['anime'] as List<dynamic>)
            .map<Anime>((e) => Anime.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  @override
  void dispose() {
    log("dispose");
    scroll.dispose();
    themesRepository.dispose();
    animeThemesRepository.dispose();
    listings.clear();
    super.dispose();
  }
}
