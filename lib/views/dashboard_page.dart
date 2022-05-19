import 'dart:developer';

import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/explore_page.dart';
import 'package:anime_themes_player/views/playlist_page.dart';
import 'package:anime_themes_player/views/search_page.dart';
import 'package:anime_themes_player/widgets/player_buttons.dart';
import 'package:audio_session/audio_session.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);
  static const routeName = '/DashboardPage';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Widget getTabFromIndex(int index) {
    switch (index) {
      case 1:
        return const SearchPage();
      case 2:
        return const PlaylistPage();
      default:
        return const ExplorePage();
    }
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player?.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      log('A stream error occurred: $e');
    });
    try {
      await _player?.setAudioSource(_playlist);
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      log("Error loading playlist: $e");
      log(stackTrace.toString());
    }
  }

  static int _nextMediaId = 0;
  AudioPlayer? _player;
  Future stopPlayer() async {
    await _player!.stop();
    await _player!.dispose();
    _player = null;
    setState(() {});
  }

  final _playlist = ConcatenatingAudioSource(children: [
    ClippingAudioSource(
      start: const Duration(seconds: 60),
      end: const Duration(seconds: 90),
      child: AudioSource.uri(Uri.parse(
          "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "A Salute To Head-Scratching Science (30 seconds)",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse(
          "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "A Salute To Head-Scratching Science",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "From Cat Rheology To Operatic Incompetence",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "From Cat Rheology To Operatic Incompetence",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
        init: DashboardController(),
        initState: (_) {
          // _player = AudioPlayer();
          // _init();
        },
        dispose: (_) {
          _player?.dispose();
        },
        builder: (c) {
          bool playerLoaded = _player != null;

          return SafeArea(
            top: false,
            right: false,
            left: false,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(playerLoaded ? 85 : 55),
                child: AppBar(
                  leading: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          color: Colors.white.withAlpha(122)),
                      child: Image.asset('lib/assets/at_comm_icon.png')),
                  title: const Text(Values.title),
                  centerTitle: true,
                  actions: [
                    Switch(
                        thumbColor:
                            MaterialStateProperty.all(Colors.grey.shade50),
                        activeThumbImage: const AssetImage(
                          Values.nightModeAsset,
                        ),
                        inactiveThumbImage:
                            const AssetImage(Values.dayModeAsset),
                        value: c.darkMode ?? false,
                        onChanged: c.changeDarkMode)
                  ],
                  bottom: PreferredSize(
                      child: !playerLoaded
                          ? const SizedBox(height: 0)
                          : PlayerButtons(
                              _player!,
                              stopPlayer: stopPlayer,
                            ),
                      preferredSize: Size.fromHeight(playerLoaded ? 50 : 0)),
                ),
              ),
              body: getTabFromIndex(c.selectedIndex.value),
              bottomNavigationBar: FancyBottomNavigation(
                  initialSelection: c.selectedIndex.value,
                  circleColor: Theme.of(context).primaryColor,
                  inactiveIconColor:
                      Theme.of(context).appBarTheme.titleTextStyle?.color ??
                          const Color(0xffffffff),
                  activeIconColor:
                      Theme.of(context).appBarTheme.titleTextStyle?.color ??
                          const Color(0xffffffff),
                  textColor:
                      Theme.of(context).appBarTheme.titleTextStyle?.color ??
                          const Color(0xffffffff),
                  // barBackgroundColor: Theme.of(context)
                  //     .bottomNavigationBarTheme
                  //     .backgroundColor,
                  tabs: [
                    TabData(
                        iconData: Icons.dashboard_outlined,
                        title: Values.explore),
                    TabData(
                        iconData: Icons.search_outlined, title: Values.search),
                    TabData(
                        iconData: Icons.queue_music_outlined,
                        title: Values.playlist)
                  ],
                  onTabChangedListener: c.updateIndex),
            ),
          );
        });
  }
}
