  
  
  import 'dart:developer';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/playlist_tracks_response.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
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
  // RxList<AudioEntry> listings = RxList.empty();
  // RxStatus status = RxStatus.empty();
  ScrollController scroll = ScrollController();
  RxList<dynamic> playlistList = RxList.empty();
  RxStatus statusPlaylist = RxStatus.success();
   RxList<dynamic> tracksList = RxList.empty();
  RxStatus statusTracks = RxStatus.success();

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


    fetchPlaylists() async {
    playlistList.clear();
    playlistList.refresh();
    statusPlaylist = playlistList.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update();
    ApiResponse apiResponse;
    apiResponse = await playlistsRepo.getMyPlaylists();
    if (apiResponse.status) {
      final PlaylistsResponse playlistsResponse = PlaylistsResponse.fromJson(apiResponse.data ) ;
      playlistList.value = playlistsResponse.playlists;
    }

    if (apiResponse.status) {
      if (playlistList.isEmpty) {
        playlistList.refresh();
        statusPlaylist = RxStatus.empty();
        update();
      } else {
        playlistList.refresh();
        statusPlaylist = RxStatus.success();
        update();
      }
    } else {
      statusPlaylist = RxStatus.error(apiResponse.message);
      playlistList.clear();
      playlistList.refresh();
      update();
    }
  }


    fetchTracks(playListId) async {
    tracksList.clear();
    tracksList.refresh();
    statusTracks = tracksList.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update();
    ApiResponse apiResponse;
    apiResponse = await playlistsRepo.getPlaylistData(playlistId: playListId);
    if (apiResponse.status) {
      final PlaylistTracksResponse tracksResponse = PlaylistTracksResponse.fromJson(apiResponse.data);
      tracksList.value = tracksResponse.tracks;
    }

    if (apiResponse.status) {
      if (tracksList.isEmpty) {
        tracksList.refresh();
        statusTracks = RxStatus.empty();
        update();
      } else {
        tracksList.refresh();
        statusTracks = RxStatus.success();
        update();
      }
    } else {
      statusTracks = RxStatus.error(apiResponse.message);
      tracksList.clear();
      tracksList.refresh();
      update();
    }
  }

  @override
  void dispose() {
    networkCalls.dispose();
    playlistsRepo.dispose();
    scroll.dispose();
    playlistList.clear();
    tracksList.clear();
    super.dispose();
  }
  }