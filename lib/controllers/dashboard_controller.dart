import 'dart:developer';

import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/online_video_player.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  GetStorage box = GetStorage();
  bool? darkMode;
  bool initializedWidgets = false;
  List<MediaItem> get mediaItems => _playlist.children
      .map<MediaItem>((e) => e.sequence.first.tag as MediaItem)
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
          await _playlist.add(AudioSource.uri(
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

  Future playFromPlayer(int index) async {
    if (playerLoaded) {
      log((_playlist.children.elementAt(index) as ProgressiveAudioSource)
          .uri
          .toString());
      await underPlayer?.seek(Duration.zero, index: index);
    }
  }

  void moveThemeInPlayer(int oldIndex, int newIndex) {
    if (playerLoaded) {
      _playlist.move(oldIndex, newIndex);
    }
  }

  bool get playerLoaded => underPlayer != null;
  @override
  void dispose() {
    underPlayer?.dispose();
    super.dispose();
  }
}
