import 'dart:developer';
import 'dart:typed_data';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/online_video_player.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  GetStorage box = GetStorage();
  bool? darkMode;
  bool initializedWidgets = false;
  final TextEditingController trackName = TextEditingController();
  late HeadlessInAppWebView headlessWebView;
  late CookieManager cookieManager;
  String csrfCookie = "";

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
  initialize() {
    box = GetStorage();
    darkMode = box.read<bool>('dark_mode') ?? false;
    selectedIndex.value = box.read<int>('selected_index') ?? 0;
    changeDarkMode(darkMode);
    initializedWidgets = true;
    Get.put<GlobalKey<OnlineVideoPlayerState>>(videoPlayerKey);
    log("initialized");
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

  Future<void> init(List<AudioEntry> audioEntries,
      {bool addToQueueOnly = false}) async {
    try {
      for (final AudioEntry audioEntry in audioEntries) {
        final int isPresent = _playlist.children.lastIndexWhere((audiosoiurce) {
          final MediaItem mediaItem =
              audiosoiurce.sequence.first.tag as MediaItem;
          return mediaItem.id == audioEntry.id.toString();
        });
        log("${_playlist.length} is current playlist length");
        if (isPresent == -1 && audioEntry.audioUrl != null) {
          _playlist.add(AudioSource.uri(
            Uri.parse(audioEntry.audioUrl!),
            tag: MediaItem(
                id: audioEntry.id,
                album: audioEntry.album,
                artist: audioEntry.artist,
                title: audioEntry.title,
                artUri: audioEntry.art,
                extras: {
                  Values.audio: audioEntry.audioUrl,
                  Values.video: audioEntry.videoUrl,
                }),
          ));
        }
      }
      log("${_playlist.length} is current playlist length");
      if (!playerLoaded) {
        underPlayer = AudioPlayer();
      } else {
        // await underPlayer?.stop();

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

  void getCookies() async {
    cookieManager = CookieManager.instance();
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri("https://animethemes.moe/"),
      ),
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true),

      // shouldInterceptRequest: (controller, request) async {
      //   var url = request.url.toString();
      //   log("VIL $url ${request.method}");
      //   final String method =
      //       ("https://api.animethemes.moe/auth/login" == url) ? 'POST' : 'GET';
      //   if (request.method == 'OPTIONS') {
      //     request.headers = {
      //       'Origin': 'https://animethemes.moe',
      //       'Referer': 'https://animethemes.moe/',
      //       'Access-Control-Request-Method': method,
      //       'Access-Control-Request-Headers': 'x-requested-with,x-xsrf-token',
      //     };
      //   }

      //   // Handle the actual POST or GET request after the preflight
      //   if (request.method == "POST" || request.method == "GET") {
      //     log("VIL Handling actual POST/GET request");
      //     // Modify or add any additional headers if necessary
      //     request.headers = {
      //       'X-Requested-With': 'XMLHttpRequest',
      //       'X-XSRF-TOKEN': csrfCookie,
      //     };
      //     return request;
      //   }
      //   return request;
      // },
      onReceivedHttpError: (controller, req, resp) {
        log('VIL error= resp=${resp.toString()}');
        log('VIL error= req=${req.toString()}');
      },
      onLoadStop: (controller, url) async {
        final List<Cookie> cookies = await cookieManager.getCookies(url: url!);
        for (var cookie in cookies) {
          if (cookie.name == 'XSRF-TOKEN') {
            log('VIL Cookie: ${Uri.decodeFull(cookie.value)}');
            if ([
              "https://animethemes.moe/",
              "https://api.animethemes.moe/sanctum/csrf-cookie"
            ].contains(url.toString())) {
              csrfCookie = Uri.decodeFull(cookie.value);
            }
          }
        }
        if ([
          "https://api.animethemes.moe/me",
          "https://api.animethemes.moe/auth/login"
        ].contains(url.toString())) {
          String? jsonResponse = await controller.evaluateJavascript(
              source: "document.body.innerText;");
          // print("Response JSON: $jsonResponse");
          log("VIL Response : $jsonResponse");
        }
      },
    );
    headlessWebView.run();
  }

  void onLoginInBrowser() {
    const String endPoint = "https://api.animethemes.moe/auth/login";
    final URLRequest optionsRequest =
        URLRequest(url: WebUri(endPoint), method: 'OPTIONS');
    final URLRequest postRequest = URLRequest(
        url: WebUri(endPoint),
        method: 'POST',
        body: Uint8List.fromList(
            '{"email":"email@gmail.com","password":"password","remember":true}'
                .codeUnits));
    headlessWebView.webViewController?.loadUrl(urlRequest: optionsRequest);
    headlessWebView.webViewController?.loadUrl(urlRequest: postRequest);
  }

  void onGetCSRFToken() {
    const String endPoint = "https://api.animethemes.moe/sanctum/csrf-cookie";
    final URLRequest optionsRequest =
        URLRequest(url: WebUri(endPoint), method: 'OPTIONS');
    final URLRequest getRequest =
        URLRequest(url: WebUri(endPoint), method: 'GET');
    headlessWebView.webViewController?.loadUrl(urlRequest: optionsRequest);
    headlessWebView.webViewController?.loadUrl(urlRequest: getRequest);
  }

  void onGetPlaylist() {
    headlessWebView.webViewController?.loadUrl(
        urlRequest: URLRequest(
            url: WebUri("https://api.animethemes.moe/me"), method: 'GET'));
  }

  @override
  void dispose() {
    underPlayer?.dispose();
    headlessWebView.webViewController?.dispose();
    headlessWebView.dispose();
    super.dispose();
  }
}
