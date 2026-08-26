import 'dart:convert';
import 'dart:developer';

import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/playlist_track.dart';
import 'package:anime_themes_player/models/playlist_songs_response.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/playlists_repo.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/current_playing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistsController extends GetxController {
  static const String _playlistsCacheKey = 'cache_playlists_me';
  static const String _refreshMetadataCacheKey = 'cache_playlist_refresh_metadata';
  static const String _playlistTracksCachePrefix = 'cache_playlist_tracks_';
  static const String _playlistTrackDetailsCachePrefix =
      'cache_playlist_track_details_';
  static const String _playlistTrackInclude =
      'video.audio,animethemeentry.animetheme.anime.images,animethemeentry.animetheme.song.artists';
  static const Duration _refreshAfter = Duration(hours: 6);
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
  final Map<String, RxList<PlaylistSongTrack>> trackDetailsByPlaylistId = {};
  final Map<String, RxStatus> trackStatusByPlaylistId = {};
  final Map<String, String?> trackNextLinkByPlaylistId = {};
  final Map<String, int> trackPageByPlaylistId = {};
  final RxSet<String> loadingMoreTrackPlaylistIds = <String>{}.obs;
  final RxSet<String> favoriteThemeIds = <String>{}.obs;
  final RxString playlistSyncProgress = ''.obs;
  final RxSet<String> syncingPlaylistTrackIds = <String>{}.obs;
  final RxSet<String> failedPlaylistSyncIds = <String>{}.obs;
  bool _favoriteThemeIdsHydrated = false;

  String _tracksCacheKey(Object playListId) =>
      '$_playlistTracksCachePrefix${playListId.toString()}';

  String _trackDetailsCacheKey(Object playListId) =>
      '$_playlistTrackDetailsCachePrefix${playListId.toString()}';

  String _refreshKeyForPlaylists() => 'playlists';

  String _refreshKeyForTracks(Object playListId) =>
      'tracks_${playListId.toString()}';

  Map<String, dynamic> _readRefreshMetadata() {
    final cached = box.read(_refreshMetadataCacheKey);
    if (cached is Map) {
      return Map<String, dynamic>.from(jsonDecode(jsonEncode(cached)));
    }
    return <String, dynamic>{};
  }

  DateTime? _readRefreshTimestamp(String refreshKey) {
    final metadata = _readRefreshMetadata();
    final value = metadata[refreshKey];
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed);
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool _isRefreshDue(String refreshKey) {
    final lastRefresh = _readRefreshTimestamp(refreshKey);
    if (lastRefresh == null) {
      return true;
    }
    return DateTime.now().difference(lastRefresh) > _refreshAfter;
  }

  Future<void> _writeRefreshTimestamp(String refreshKey) async {
    final metadata = _readRefreshMetadata();
    metadata[refreshKey] = DateTime.now().millisecondsSinceEpoch;
    await box.write(_refreshMetadataCacheKey, metadata);
  }

  Future<void> clearRefreshMetadata() async {
    await box.remove(_refreshMetadataCacheKey);
  }

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

  RxList<PlaylistSongTrack> trackDetailsFor(Object playListId) {
    final key = playListId.toString();
    return trackDetailsByPlaylistId.putIfAbsent(key, () => RxList.empty());
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

  bool hasFailedPlaylistSync(Object playlistId) {
    return failedPlaylistSyncIds.contains(playlistId.toString());
  }

  bool isSyncingPlaylist(Object playlistId) {
    return syncingPlaylistTrackIds.contains(playlistId.toString());
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

  bool shouldRefreshPlaylistsFromServer({bool forceRefresh = false}) {
    if (forceRefresh) return true;
    return _isRefreshDue(_refreshKeyForPlaylists());
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

  bool shouldRefreshTracksFromServer(
    Object playListId, {
    bool forceRefresh = false,
  }) {
    if (forceRefresh) return true;
    return _isRefreshDue(_refreshKeyForTracks(playListId));
  }

  bool hydrateTrackDetailsFromCache(Object playListId) {
    final trackDetails = trackDetailsFor(playListId);
    if (trackDetails.isNotEmpty) return true;
    final cached = _readCachedMap(_trackDetailsCacheKey(playListId));
    if (cached == null) return false;
    final details = ((cached['tracks'] as List?) ?? [])
        .map((e) => PlaylistSongTrack.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    trackDetails.value = details;
    trackDetails.refresh();
    update();
    return trackDetails.isNotEmpty;
  }

  Future<void> _cachePlaylistTrackDetails(
    String playlistId,
    Iterable<PlaylistSongTrack> tracks,
  ) async {
    final trackDetails = trackDetailsFor(playlistId);
    final mergedTracks = <String, PlaylistSongTrack>{
      for (final track in trackDetails) track.id: track,
    };

    for (final track in tracks) {
      mergedTracks[track.id] = track;
    }

    trackDetails.value = mergedTracks.values.toList();
    trackDetails.refresh();
    await box.write(_trackDetailsCacheKey(playlistId), {
      'tracks': trackDetails.map((track) => track.toJson()).toList(),
    });
  }

  Future<bool> _downloadPlaylistTrackDetails({
    required String playlistId,
  }) async {
    final firstPageResponse = await playlistsRepo.getPlaylistSongs(
      playlistId: playlistId,
      pageSize: 100,
      pageNumber: 1,
      include: _playlistTrackInclude,
    );

    if (!firstPageResponse.status ||
        firstPageResponse.data is! Map<String, dynamic>) {
      return false;
    }

    var page = PlaylistSongsResponse.fromJson(
      Map<String, dynamic>.from(firstPageResponse.data),
    );
    await _cachePlaylistTrackDetails(playlistId, page.tracks);

    String? nextUrl = page.links.next;
    while (nextUrl != null) {
      final pageResponse = await playlistsRepo.getPlaylistSongsByUrl(
        nextUrl,
        include: _playlistTrackInclude,
      );

      if (!pageResponse.status || pageResponse.data is! Map<String, dynamic>) {
        return false;
      }

      page = PlaylistSongsResponse.fromJson(
        Map<String, dynamic>.from(pageResponse.data),
      );
      await _cachePlaylistTrackDetails(playlistId, page.tracks);
      nextUrl = page.links.next;
    }

    return true;
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
      await box.remove(_trackDetailsCacheKey(playlistId));
      tracksByPlaylistId.remove(playlistId);
      trackDetailsByPlaylistId.remove(playlistId);
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
      await box.remove(_trackDetailsCacheKey(playlistId));
      tracksByPlaylistId.remove(playlistId);
      trackDetailsByPlaylistId.remove(playlistId);
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
      trackDetailsByPlaylistId.remove(playlistId);
      await box.remove(_trackDetailsCacheKey(playlistId));
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
    if (hasCachedPlaylists &&
        !shouldRefreshPlaylistsFromServer(forceRefresh: forceRefresh)) {
      return;
    }
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
      await _writeRefreshTimestamp(_refreshKeyForPlaylists());
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
      if (playlistList.isEmpty) {
        statusPlaylist = RxStatus.error(apiResponse.message);
        playlistList.clear();
        playlistList.refresh();
      } else {
        statusPlaylist = RxStatus.success();
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
      final PlaylistSongsResponse tracksResponse =
          PlaylistSongsResponse.fromJson(
        Map<String, dynamic>.from(apiResponse.data),
      );
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
    int pageSize = 100,
    int pageNumber = 1,
  }) async {
    final response = await playlistsRepo.getPlaylistSongs(
      playlistId: playlistId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    if (!response.status || response.data is! Map<String, dynamic>) {
      return null;
    }

    final playlistSongsResponse = PlaylistSongsResponse.fromJson(
        Map<String, dynamic>.from(response.data));
    log('getPlaylistSongsResponse: ${playlistSongsResponse.toJson()}');
    return playlistSongsResponse;
  }

  Future<List<String>> _fetchAllPlaylistTrackIds(String playlistId) async {
    final trackIds = <String>[];
    String? nextUrl =
        '${Values.baseUrl}/playlist/$playlistId/track?page[size]=100&page[number]=1';

    while (nextUrl != null) {
      final pageResponse = await playlistsRepo.getPlaylistSongsByUrl(nextUrl);
      if (!pageResponse.status || pageResponse.data is! Map<String, dynamic>) {
        break;
      }

      final page = PlaylistSongsResponse.fromJson(
        Map<String, dynamic>.from(pageResponse.data),
      );
      trackIds.addAll(page.tracks.map((track) => track.id));
      nextUrl = page.links.next;
    }

    return trackIds;
  }

  Future<void> syncPlaylistTrackDetails({
    required String playlistId,
    required String playlistName,
  }) async {
    syncingPlaylistTrackIds.add(playlistId);
    failedPlaylistSyncIds.remove(playlistId);
    final trackDetails = trackDetailsFor(playlistId);
    hydrateTrackDetailsFromCache(playlistId);

    try {
      final allTrackIds = await _fetchAllPlaylistTrackIds(playlistId);
      final existingTrackIds = trackDetails.map((track) => track.id).toSet();
      final hasAllCachedTracks = allTrackIds.isNotEmpty &&
          allTrackIds.every(existingTrackIds.contains);

      if (allTrackIds.isEmpty || hasAllCachedTracks) {
        playlistSyncProgress.value =
            '(${existingTrackIds.length}/${allTrackIds.length} Synced)';
        failedPlaylistSyncIds.remove(playlistId);
        playlistSyncProgress.value = '';
        syncingPlaylistTrackIds.remove(playlistId);
        await loadPlaylistSongsToCurrentPlaying(
          playlistId: playlistId,
          playlistName: playlistName,
        );
        return;
      }

      playlistSyncProgress.value = '(0/${allTrackIds.length} Synced)';
      update();

      final downloadSucceeded = await _downloadPlaylistTrackDetails(
        playlistId: playlistId,
      );

      if (!downloadSucceeded) {
        failedPlaylistSyncIds.add(playlistId);
        playlistSyncProgress.value =
            '(${trackDetails.length}/${allTrackIds.length} Synced, Retry needed)';
        update();
        return;
      }

      final refreshedTrackIds =
          trackDetailsFor(playlistId).map((track) => track.id).toSet();
      final missingTrackIds = allTrackIds
          .where((trackId) => !refreshedTrackIds.contains(trackId))
          .toList();

      if (missingTrackIds.isNotEmpty) {
        failedPlaylistSyncIds.add(playlistId);
        playlistSyncProgress.value =
            '(${refreshedTrackIds.length}/${allTrackIds.length} Synced, ${missingTrackIds.length} Missing)';
        update();
        return;
      }

      failedPlaylistSyncIds.remove(playlistId);
      playlistSyncProgress.value = '';
      syncingPlaylistTrackIds.remove(playlistId);

      await loadPlaylistSongsToCurrentPlaying(
        playlistId: playlistId,
        playlistName: playlistName,
      );
    } finally {
      syncingPlaylistTrackIds.remove(playlistId);
      update();
    }
  }

  Future<void> loadPlaylistSongsToCurrentPlaying({
    required String playlistId,
    required String playlistName,
  }) async {
    final trackDetails = trackDetailsFor(playlistId);
    if (trackDetails.isEmpty && !hydrateTrackDetailsFromCache(playlistId)) {
      return;
    }

    final queue = trackDetails.map((track) {
      final video = track.video;
      return PlaylistSongTrack.queue(
        id: track.id,
        videoId: video.id,
        basename: video.basename,
        filename: video.filename,
        audioUrl: video.audio.link,
        videoUrl: video.link,
        album: track.resolvedAlbum,
        title: track.resolvedTitle,
        artist: track.resolvedArtist,
        coverUrl: track.resolvedCoverUrl,
      );
    }).toList();

    queue.shuffle();
    final dashboardController = Get.find<DashboardController>();
    if (dashboardController.playerLoaded) {
      await dashboardController.stopPlayer();
    }
    if (Get.currentRoute != CurrentPlaying.routeName) {
      Get.toNamed(CurrentPlaying.routeName);
    }
    await dashboardController.init(queue);
  }

  Future<void> playPlaylistTrackNow({
    required PlaylistTrack track,
    required String playlistName,
  }) async {
    final theme = track.animethemeentry.animetheme;
    final anime = theme.anime;
    final song = theme.song;
    final artistName = song.artists.map((artist) => artist.name).join(',');
    final coverUrl = anime.images.isNotEmpty ? anime.images.first.link : null;

    final dashboardController = Get.find<DashboardController>();
    if (dashboardController.playerLoaded) {
      await dashboardController.stopPlayer();
    }
    if (Get.currentRoute != CurrentPlaying.routeName) {
      Get.toNamed(CurrentPlaying.routeName);
    }
    await dashboardController.init([
      PlaylistSongTrack.queue(
        id: track.id,
        videoId: track.video.id,
        basename: track.video.basename,
        filename: track.video.filename,
        audioUrl: track.video.audio.link,
        videoUrl: track.video.link,
        album: anime.name,
        title: song.title,
        artist: artistName,
        coverUrl: coverUrl,
      ),
    ]);
  }

  Future<void> fetchTracks(playListId, {bool forceRefresh = false}) async {
    final tracks = tracksFor(playListId);
    final hasCachedTracks = hydrateTracksFromCache(playListId);
    if (hasCachedTracks &&
        !shouldRefreshTracksFromServer(playListId, forceRefresh: forceRefresh)) {
      return;
    }
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
      await _writeRefreshTimestamp(_refreshKeyForTracks(playListId));
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
      if (tracks.isEmpty) {
        _setTrackStatus(playListId, RxStatus.error(apiResponse.message));
        tracks.clear();
        tracks.refresh();
      } else {
        _setTrackStatus(playListId, RxStatus.success());
      }
      statusTracks = statusForTracks(playListId);
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
      await _writeRefreshTimestamp(_refreshKeyForTracks(playlistId));
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
    trackDetailsByPlaylistId.clear();
    playlistSyncProgress.value = '';
    syncingPlaylistTrackIds.clear();
    super.dispose();
  }
}
