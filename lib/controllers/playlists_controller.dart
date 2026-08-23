import 'dart:convert';
import 'dart:developer';

import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/playlist_track.dart';
import 'package:anime_themes_player/models/playlist_tracks_file_list.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/playlists_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistsController extends GetxController {
  static const String _playlistsCacheKey = 'cache_playlists_me';
  static const String _playlistTracksCachePrefix = 'cache_playlist_tracks_';
  AnimeThemeRepository networkCalls = AnimeThemeRepository();
  final PlaylistsRepo playlistsRepo = PlaylistsRepo();
  final RxBool wait = false.obs;
  final RxString toastMessage = "".obs;
  GetStorage box = GetStorage();
  // RxList<AudioEntry> listings = RxList.empty();
  // RxStatus status = RxStatus.empty();
  ScrollController scroll = ScrollController();
  RxList<dynamic> playlistList = RxList.empty();
  RxStatus statusPlaylist = RxStatus.error("");
  RxList<dynamic> tracksList = RxList.empty();
  RxStatus statusTracks = RxStatus.error("");
  final Map<String, RxList<dynamic>> tracksByPlaylistId = {};
  final Map<String, RxStatus> trackStatusByPlaylistId = {};

  String _tracksCacheKey(Object playListId) =>
      '$_playlistTracksCachePrefix${playListId.toString()}';

  Map<String, dynamic>? _readCachedMap(String key) {
    final cached = box.read(key);
    if (cached is Map) {
      return Map<String, dynamic>.from(jsonDecode(jsonEncode(cached)));
    }
    return null;
  }

  RxList<dynamic> tracksFor(Object playListId) {
    final key = playListId.toString();
    return tracksByPlaylistId.putIfAbsent(key, () => RxList.empty());
  }

  RxStatus statusForTracks(Object playListId) {
    return trackStatusByPlaylistId[playListId.toString()] ?? RxStatus.error("");
  }

  void _setTrackStatus(Object playListId, RxStatus status) {
    trackStatusByPlaylistId[playListId.toString()] = status;
  }

  bool hydratePlaylistsFromCache() {
    if (playlistList.isNotEmpty) return true;
    final cached = _readCachedMap(_playlistsCacheKey);
    if (cached == null) return false;
    final playlistsResponse = PlaylistsResponse.fromJson(cached);
    playlistList.value = playlistsResponse.playlists;
    statusPlaylist =
        playlistList.isEmpty ? RxStatus.empty() : RxStatus.success();
    playlistList.refresh();
    update();
    return playlistList.isNotEmpty;
  }

  bool hydrateTracksFromCache(Object playListId) {
    final tracks = tracksFor(playListId);
    if (tracks.isNotEmpty) return true;
    final cached = _readCachedMap(_tracksCacheKey(playListId));
    if (cached == null) return false;
    final tracksResponse = PlaylistTracksData.fromJson(cached);
    tracks.value = tracksResponse.tracks;
    _setTrackStatus(
        playListId, tracks.isEmpty ? RxStatus.empty() : RxStatus.success());
    tracks.refresh();
    update();
    return tracks.isNotEmpty;
  }

  Future printdata() async {
    wait.value = true;
    final response2 =
        await playlistsRepo.getPlaylistData(playlistId: "qM3YiDJW");
    log(response2.data.toString());
    wait.value = false;
    update();
  }

  void fetchPlaylists({bool forceRefresh = false}) async {
    final hasCachedPlaylists = hydratePlaylistsFromCache();
    if (hasCachedPlaylists && !forceRefresh) return;
    if (!forceRefresh &&
        (statusPlaylist.isError &&
                statusPlaylist.errorMessage?.isEmpty == true) ==
            false) {
      return;
    }
    if (!hasCachedPlaylists) {
      playlistList.clear();
      playlistList.refresh();
    }
    statusPlaylist =
        playlistList.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update();
    ApiResponse apiResponse;
    apiResponse = await playlistsRepo.getMyPlaylists();
    if (apiResponse.status) {
      await box.write(_playlistsCacheKey, apiResponse.data);
      final PlaylistsResponse playlistsResponse =
          PlaylistsResponse.fromJson(apiResponse.data);
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
      if (playlistList.isEmpty) {
        playlistList.clear();
        playlistList.refresh();
      }
      update();
    }
  }

  void fetchTrackFiles(playListId) async {
    tracksList.clear();
    tracksList.refresh();
    statusTracks =
        tracksList.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update();
    ApiResponse apiResponse;
    apiResponse = await playlistsRepo.getPlaylistSongs(playlistId: playListId);
    if (apiResponse.status) {
      final PlaylistTracksFileList tracksResponse =
          PlaylistTracksFileList.fromJson(apiResponse.data);
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

  void fetchTracks(playListId, {bool forceRefresh = false}) async {
    final tracks = tracksFor(playListId);
    final hasCachedTracks = hydrateTracksFromCache(playListId);
    if (hasCachedTracks && !forceRefresh) return;
    final currentStatus = statusForTracks(playListId);
    if (!forceRefresh &&
        (currentStatus.isError &&
                currentStatus.errorMessage?.isEmpty == true) ==
            false) {
      return;
    }
    if (!hasCachedTracks) {
      tracks.clear();
      tracks.refresh();
    }
    _setTrackStatus(playListId,
        tracks.isEmpty ? RxStatus.loading() : RxStatus.loadingMore());
    statusTracks = statusForTracks(playListId);
    update();
    ApiResponse apiResponse;
    apiResponse = await playlistsRepo.getPlaylistData(playlistId: playListId);
    if (apiResponse.status) {
      await box.write(_tracksCacheKey(playListId), apiResponse.data);
      final PlaylistTracksData tracksResponse =
          PlaylistTracksData.fromJson(apiResponse.data);
      tracks.value = tracksResponse.tracks;
      tracksList = tracks;
    }

    if (apiResponse.status) {
      if (tracks.isEmpty) {
        tracks.refresh();
        _setTrackStatus(playListId, RxStatus.empty());
        statusTracks = statusForTracks(playListId);
        update();
      } else {
        tracks.refresh();
        _setTrackStatus(playListId, RxStatus.success());
        statusTracks = statusForTracks(playListId);
        update();
      }
    } else {
      _setTrackStatus(playListId, RxStatus.error(apiResponse.message));
      statusTracks = statusForTracks(playListId);
      if (tracks.isEmpty) {
        tracks.clear();
        tracks.refresh();
      }
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
    tracksByPlaylistId.clear();
    trackStatusByPlaylistId.clear();
    super.dispose();
  }
}
