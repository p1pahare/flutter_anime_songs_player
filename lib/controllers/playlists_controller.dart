import 'dart:convert';
import 'dart:developer';

import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/playlist_track.dart';
import 'package:anime_themes_player/models/playlist_tracks_file_list.dart';
import 'package:anime_themes_player/models/playlist_songs_response.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/playlists_repo.dart';
import 'package:anime_themes_player/views/current_playing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistsController extends GetxController {
  static const String _playlistsCacheKey = 'cache_playlists_me';
  static const String _playlistTracksCachePrefix = 'cache_playlist_tracks_';
  static const String _favoriteThemeIdsCacheKey = 'favorite_theme_ids';
  AnimeThemeRepository networkCalls = AnimeThemeRepository();
  final PlaylistsRepo playlistsRepo = PlaylistsRepo();
  final RxBool wait = false.obs;
  final RxString toastMessage = "".obs;
  GetStorage box = GetStorage();
  // RxStatus status = RxStatus.empty();
  ScrollController scroll = ScrollController();
  RxList<dynamic> playlistList = RxList.empty();
  RxStatus statusPlaylist = RxStatus.error("");
  RxList<dynamic> tracksList = RxList.empty();
  RxStatus statusTracks = RxStatus.error("");
  final Map<String, RxList<dynamic>> tracksByPlaylistId = {};
  final Map<String, RxStatus> trackStatusByPlaylistId = {};
  final Map<String, String?> trackNextLinkByPlaylistId = {};
  final Map<String, int> trackPageByPlaylistId = {};
  final RxSet<String> loadingMoreTrackPlaylistIds = <String>{}.obs;
  final RxSet<String> favoriteThemeIds = <String>{}.obs;
  bool _favoriteThemeIdsHydrated = false;

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

  bool hasMoreTracks(Object playListId) {
    final playlistId = playListId.toString();
    return trackNextLinkByPlaylistId[playlistId] != null;
  }

  bool isLoadingMoreTracks(Object playListId) {
    return loadingMoreTrackPlaylistIds.contains(playListId.toString());
  }

  void hydrateFavoriteThemeIds() {
    if (_favoriteThemeIdsHydrated) return;
    final cached = box.read(_favoriteThemeIdsCacheKey);
    if (cached is List) {
      favoriteThemeIds
        ..clear()
        ..addAll(cached.map((id) => id.toString()).toSet());
    }
    _favoriteThemeIdsHydrated = true;
  }

  bool isThemeFavorited(Object themeId) {
    hydrateFavoriteThemeIds();
    return favoriteThemeIds.contains(themeId.toString());
  }

  Future toggleThemeFavorite(Object themeId) async {
    hydrateFavoriteThemeIds();
    final themeIdText = themeId.toString();
    if (favoriteThemeIds.contains(themeIdText)) {
      favoriteThemeIds.remove(themeIdText);
    } else {
      favoriteThemeIds.add(themeIdText);
    }
    await box.write(_favoriteThemeIdsCacheKey, favoriteThemeIds.toList());
    favoriteThemeIds.refresh();
    update();
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
    trackNextLinkByPlaylistId[playListId.toString()] =
        cached['links']?['next']?.toString();
    trackPageByPlaylistId[playListId.toString()] =
        cached['meta']?['current_page'] is int
            ? cached['meta']['current_page'] as int
            : 1;
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

  Future createPlaylist({required String name}) async {
    wait.value = true;
    toastMessage.value = "";
    update();
    final apiResponse = await playlistsRepo.createPlaylist(
      name: name,
      visibility: "Public",
    );
    wait.value = false;
    toastMessage.value = apiResponse.message;
    if (apiResponse.status) {
      await box.remove(_playlistsCacheKey);
      await fetchPlaylists(forceRefresh: true);
    }
    update();
  }

  Future<bool> deletePlaylist({required String playlistId}) async {
    wait.value = true;
    toastMessage.value = "";
    update();
    final apiResponse = await playlistsRepo.deletePlaylist(
      playlistId: playlistId,
    );
    wait.value = false;
    toastMessage.value = apiResponse.message;
    if (apiResponse.status) {
      playlistList.removeWhere((playlist) => playlist.id == playlistId);
      await box.remove(_playlistsCacheKey);
      await box.remove(_tracksCacheKey(playlistId));
      tracksByPlaylistId.remove(playlistId);
      trackStatusByPlaylistId.remove(playlistId);
      trackNextLinkByPlaylistId.remove(playlistId);
      trackPageByPlaylistId.remove(playlistId);
      playlistList.refresh();
      statusPlaylist =
          playlistList.isEmpty ? RxStatus.empty() : RxStatus.success();
    }
    update();
    return apiResponse.status;
  }

  Future<ApiResponse> addTrackToPlaylist({
    required String playlistId,
    required int videoId,
    required int entryId,
  }) async {
    wait.value = true;
    toastMessage.value = "";
    update();

    final checkResponse = await playlistsRepo.checkTrackOnPlaylist(
      videoId: videoId,
    );
    if (checkResponse.status) {
      final data = checkResponse.data;
      if (data is Map<String, dynamic>) {
        final rawPlaylists = data['playlists'];
        if (rawPlaylists is List) {
          final selectedPlaylist = rawPlaylists.cast<dynamic>().firstWhere(
                (playlist) =>
                    playlist is Map && playlist['id']?.toString() == playlistId,
                orElse: () => null,
              );
          final tracksCount = int.tryParse(
                selectedPlaylist is Map
                    ? selectedPlaylist['tracks_count']?.toString() ?? '0'
                    : '0',
              ) ??
              0;
          final tracks =
              selectedPlaylist is Map ? selectedPlaylist['tracks'] : null;
          final hasTrackList = tracks is List && tracks.isNotEmpty;
          final alreadyInPlaylist = tracksCount > 0 || hasTrackList;
          if (alreadyInPlaylist) {
            wait.value = false;
            toastMessage.value = 'Theme already exists in this playlist.';
            update();
            return ApiResponse(
              status: false,
              message: toastMessage.value,
              data: checkResponse.data,
            );
          }
        }
      }
    }

    final apiResponse = await playlistsRepo.addTrackToPlaylist(
      playlistId: playlistId,
      videoId: videoId,
      entryId: entryId,
    );
    wait.value = false;
    toastMessage.value = apiResponse.message;
    if (apiResponse.status) {
      await box.remove(_tracksCacheKey(playlistId));
      tracksByPlaylistId.remove(playlistId);
      trackStatusByPlaylistId.remove(playlistId);
      trackNextLinkByPlaylistId.remove(playlistId);
      trackPageByPlaylistId.remove(playlistId);
    }
    update();
    return apiResponse;
  }

  Future<bool> deleteTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    wait.value = true;
    toastMessage.value = "";
    update();
    final apiResponse = await playlistsRepo.deleteTrackFromPlaylist(
      playlistId: playlistId,
      trackId: trackId,
    );
    wait.value = false;
    toastMessage.value = apiResponse.message;
    if (apiResponse.status) {
      final tracks = tracksFor(playlistId);
      tracks.removeWhere((track) => track.id == trackId);
      tracks.refresh();
      await box.remove(_tracksCacheKey(playlistId));
      _setTrackStatus(
        playlistId,
        tracks.isEmpty ? RxStatus.empty() : RxStatus.success(),
      );
    }
    update();
    return apiResponse.status;
  }

  Future<void> fetchPlaylists({bool forceRefresh = false}) async {
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

  Future<PlaylistSongsResponse?> getPlaylistSongsResponse({
    required String playlistId,
  }) async {
    final response =
        await playlistsRepo.getPlaylistSongs(playlistId: playlistId);
    if (!response.status || response.data is! Map<String, dynamic>) {
      return null;
    }

    final playlistSongsResponse = PlaylistSongsResponse.fromJson(
        Map<String, dynamic>.from(response.data));
    log('getPlaylistSongsResponse: ${playlistSongsResponse.toJson()}');
    return playlistSongsResponse;
  }

  Future<void> loadPlaylistSongsToCurrentPlaying({
    required String playlistId,
    required String playlistName,
  }) async {
    final playlistSongsResponse = await getPlaylistSongsResponse(
      playlistId: playlistId,
    );
    if (playlistSongsResponse == null || playlistSongsResponse.tracks.isEmpty) {
      return;
    }

    final queue = playlistSongsResponse.tracks.map((track) {
      final video = track.video;
      return PlaylistSongTrack.queue(
        id: track.id,
        videoId: video.id,
        basename: video.basename,
        filename: video.filename,
        audioUrl: video.audio.link,
        videoUrl: video.link,
        album: playlistName,
        title: video.filename.isNotEmpty ? video.filename : video.basename,
      );
    }).toList();

    queue.shuffle();
    final dashboardController = Get.find<DashboardController>();
    if (dashboardController.playerLoaded) {
      await dashboardController.stopPlayer();
    }
    await dashboardController.init(queue);
    Get.toNamed(CurrentPlaying.routeName);
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
      trackPageByPlaylistId[playListId.toString()] = 1;
      trackNextLinkByPlaylistId[playListId.toString()] =
          apiResponse.data?['links']?['next']?.toString();
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

  Future<ApiResponse> fetchMoreTracks({required String playlistId}) async {
    final tracks = tracksFor(playlistId);
    final nextLink = trackNextLinkByPlaylistId[playlistId];
    if (nextLink == null) {
      return ApiResponse(
        status: false,
        message: 'No more tracks',
        data: false,
      );
    }

    loadingMoreTrackPlaylistIds.add(playlistId);
    update();

    final currentPage = trackPageByPlaylistId[playlistId] ?? 1;
    final apiResponse = await playlistsRepo.getPlaylistData(
      playlistId: playlistId,
      pageNumber: currentPage + 1,
    );

    if (apiResponse.status) {
      final tracksResponse = PlaylistTracksData.fromJson(apiResponse.data);
      tracks.addAll(tracksResponse.tracks);
      tracks.refresh();
      trackPageByPlaylistId[playlistId] = currentPage + 1;
      trackNextLinkByPlaylistId[playlistId] =
          apiResponse.data?['links']?['next']?.toString();
      await box.write(_tracksCacheKey(playlistId), {
        'tracks':
            tracks.map((track) => (track as PlaylistTrack).toJson()).toList(),
        'links': apiResponse.data['links'],
        'meta': apiResponse.data['meta'],
      });
    } else {
      toastMessage.value = apiResponse.message;
    }

    loadingMoreTrackPlaylistIds.remove(playlistId);
    update();

    return apiResponse;
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
    favoriteThemeIds.clear();
    super.dispose();
  }
}
