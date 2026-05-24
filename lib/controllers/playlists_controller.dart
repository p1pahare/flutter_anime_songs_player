  
  
  import 'dart:developer';

import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/playlists_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistsController extends GetxController {
  AnimeThemeRepository networkCalls = AnimeThemeRepository();
  final PlaylistsRepo playlistsRepo = PlaylistsRepo();
  final RxBool wait = false.obs;
  final RxString toastMessage = "".obs;
  GetStorage box = GetStorage();
  RxList<AudioEntry> listings = RxList.empty();
  RxStatus status = RxStatus.empty();
  ScrollController scroll = ScrollController();


  Future printdata() async {
    wait.value = true;
    final response = await playlistsRepo.getMyPlaylists();
    final response2 = await playlistsRepo.getPlaylistSongs(playlistId: "qM3YiDJW");
    log(response2.data.toString());
    log(  response.data.toString());
    wait.value = false;
    toastMessage.value = response.message;
    update();
  }

  @override
  void dispose() {
    networkCalls.dispose();
    playlistsRepo.dispose();
    scroll.dispose();
    listings.clear();
    super.dispose();
  }
  }