import 'dart:async';
import 'dart:developer';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.

class OnlineVideoPlayer extends StatefulWidget {
  const OnlineVideoPlayer({GlobalKey<OnlineVideoPlayerState>? key})
      : super(key: key);
  @override
  State<OnlineVideoPlayer> createState() => OnlineVideoPlayerState();
}

class OnlineVideoPlayerState extends State<OnlineVideoPlayer> {
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final videoController = VideoController(player);
  Duration currentPosition = Duration.zero;
  RxBool itIsLoading = false.obs;
  @override
  void initState() {
    super.initState();
    setDataSource();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> setDataSource({int? index}) async {
    itIsLoading = true.obs;
    log("itIsloading set to ${itIsLoading.value}");
    // set the data source and play the video in the last video position
    final int currentIndex =
        index ?? Get.find<DashboardController>().underPlayer?.currentIndex ?? 0;
    final String videoUrl = Get.find<DashboardController>()
            .mediaItems[currentIndex]
            .extras?[Values.video] ??
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    // Play a [Media] or [Playlist].
    player.open(Media(videoUrl));
    player.seek(
      index != null
          ? Duration.zero
          : Get.find<DashboardController>().underPlayer?.position ??
              currentPosition,
    );
    player.stream.duration.listen((position) {
      currentPosition = position;
    });
    player.stream.playing.listen((event) {});
    player.stream.completed.listen((completed) async {
      if (completed) {
        if (Get.find<DashboardController>().underPlayer?.hasNext ?? false) {
          await Get.find<DashboardController>().underPlayer?.seekToNext();
          await setDataSource(
              index: Get.find<DashboardController>().underPlayer?.currentIndex);
        }
      }
    });
    itIsLoading = false.obs;
    log("itIsloading set to ${itIsLoading.value}");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height * 0.28,
      child: ObxValue<RxBool>((loading) {
        return loading.isTrue
            ? const Center(child: ProgressIndicatorButton())
            : AspectRatio(
                aspectRatio: player.state.videoParams.aspect ?? 1.775,
                child: Video(controller: videoController),
              );
      }, itIsLoading),
    );
  }
}
