import 'dart:developer';
import 'package:anime_themes_player/controllers/users_controller.dart';
import 'package:anime_themes_player/models/login_models.dart';
import 'package:anime_themes_player/models/playlist_songs_response.dart';
import 'package:anime_themes_player/repositories/users_repo.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/online_video_player.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var currentTitle = Values.title.obs;
  var currentImage = "".obs;
  GetStorage box = GetStorage();
  bool? darkMode;
  bool initializedWidgets = false;
  final Rxn<Me> _me = Rxn<Me>();

  Me? get me => _me.value;
  set me(Me? value) => _me.value = value;
  final TextEditingController trackName = TextEditingController();
  final UsersRepo usersRepo = UsersRepo();
  List<MediaItem> get mediaItems => _playlist.children
      .map<MediaItem>((e) => e.sequence.first.tag as MediaItem)
      .where((element) => trackName.text.isEmpty
          ? true
          : (element.title
                  .toLowerCase()
                  .contains(trackName.text.toLowerCase()) ||
              (element.album
                      ?.toLowerCase()
                      .contains(trackName.text.toLowerCase()) ??
                  false)))
      .toList();
  final GlobalKey<OnlineVideoPlayerState> videoPlayerKey = GlobalKey();

  bool? _systemDarkMode() {
    try {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    } catch (_) {
      return null;
    }
  }

  initialize() {
    box = GetStorage();
    darkMode = _systemDarkMode() ?? true;
    selectedIndex.value = box.read<int>('selected_index') ?? 0;
    changeDarkMode(darkMode);
    initializedWidgets = true;
    Get.put<GlobalKey<OnlineVideoPlayerState>>(videoPlayerKey);
    log("initialized");
    isLogin();
  }

  changeDarkMode(bool? status) async {
    darkMode = status;

    Get.changeThemeMode(status ?? false ? ThemeMode.dark : ThemeMode.light);
    await box.write('dark_mode', status);
    await Future.delayed(const Duration(milliseconds: 200));
    update();
  }

  void updateIndex(int? index) async {
    selectedIndex.value = index ?? 0;
    await box.write('selected_index', selectedIndex.value);
    update();
  }

  Future<void> init(List<PlaylistSongTrack> playlistSongs,
      {bool addToQueueOnly = false}) async {
    try {
      for (final PlaylistSongTrack playlistSong in playlistSongs) {
        final int isPresent = _playlist.children.lastIndexWhere((audiosoiurce) {
          final MediaItem mediaItem =
              audiosoiurce.sequence.first.tag as MediaItem;
          return mediaItem.id == playlistSong.id;
        });
        log("${_playlist.length} is current playlist length");
        if (isPresent == -1 && playlistSong.audioUrl.isNotEmpty) {
          await _playlist.add(AudioSource.uri(
            Uri.parse(playlistSong.audioUrl),
            tag: MediaItem(
                id: playlistSong.id,
                album: playlistSong.album,
                artist: playlistSong.artist,
                title: playlistSong.displayTitle,
                artUri: playlistSong.artUri,
                extras: {
                  Values.audio: playlistSong.audioUrl,
                  Values.video: playlistSong.videoUrl,
                }),
          ));
        }
      }
      log("${_playlist.length} is current playlist length");
      if (!playerLoaded) {
        underPlayer = AudioPlayer();
      } else {
        if (!addToQueueOnly) {
          await underPlayer?.seek(Duration.zero, index: _playlist.length - 1);
          await underPlayer?.play();
        }
        return;
      }

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      // Listen to errors during playback.
      underPlayer?.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace stackTrace) {
        log('A stream error occurred: $e');
      });
      update();

      await underPlayer?.setAudioSource(_playlist);
      if (!addToQueueOnly) {
        log("${_playlist.length} is current playlist length");
        await underPlayer?.play();
      }
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      log("Error loading playlist: $e");
      log(stackTrace.toString());
    }
  }

  AudioPlayer? underPlayer;
  Future stopPlayer() async {
    await underPlayer!.stop();
    await underPlayer!.dispose();
    await _playlist.clear();
    underPlayer = null;
    update();
  }

  final _playlist = ConcatenatingAudioSource(
    children: [],
  );
  AudioSource? currentAudioSource(int index) {
    if (_playlist.length <= index || index < 0) {
      return null;
    } else {
      return _playlist.children.elementAt(index);
    }
  }

  Future removeThemeFromPlayer(int index) async {
    if (playerLoaded) {
      await _playlist.removeAt(index);
      update();
    }
  }

  Future playFromPlayer(String albumId) async {
    if (playerLoaded) {
      try {
        final index = _playlist.children.indexWhere((element) =>
            (element.sequence.first.tag as MediaItem).id == albumId);

        log((_playlist.children.elementAt(index) as ProgressiveAudioSource)
            .uri
            .toString());

        await underPlayer?.seek(Duration.zero, index: index);
      } catch (_) {}
    }
  }

  int getIndexFromAlbumId(String? albumId) {
    try {
      final index = _playlist.children.indexWhere(
          (element) => (element.sequence.first.tag as MediaItem).id == albumId);
      return index;
    } catch (_) {
      return 0;
    }
  }

  void moveThemeInPlayer(int oldIndex, int newIndex) {
    if (playerLoaded) {
      _playlist.move(oldIndex, newIndex);
    }
  }

  bool get playerLoaded => underPlayer != null;

  Future isLogin() async {
    UsersController playlistController = Get.find();
    playlistController.mode.value = LoginMode.loading;
    playlistController.update();
    final isLogin = await usersRepo.getUserDetails();
    if (isLogin.status) {
      me = meFromJson(isLogin.data);
      currentTitle.value = me?.user.name ?? Values.title;
      currentImage.value = usersRepo.gravatarUrlFromEmail(me?.user.email);
      playlistController.mode.value = LoginMode.loggedIn;
    } else {
      final savedEmail = box.read<String>('SAVED_LOGIN_EMAIL');
      final savedPassword = box.read<String>('SAVED_LOGIN_PASSWORD');
      if (savedEmail != null && savedPassword != null) {
        final usersController = Get.find<UsersController>();
        final autoLoggedIn = await usersController.loginWithSavedCredentials();
        if (autoLoggedIn) {
          playlistController.update();
          update();
          return;
        }
      }
      if (isLogin.data == false) {
        showMessage(Values.noInternetMessage);
        playlistController.mode.value = LoginMode.failed;
      } else {
        playlistController.mode.value = LoginMode.login;
        me = null;
        currentTitle.value = "";
        currentImage.value = "";
      }
    }
    playlistController.update();
    update();
  }

  Future<String> getVersionInfo() async {
    return "V1.0.0 (Build 1)";
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;
    // return "V$version (Build $buildNumber)";
  }

  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar("Error", "Could not launch $url");
    }
  }

  @override
  void dispose() {
    underPlayer?.dispose();
    usersRepo.dispose();
    super.dispose();
  }
}
