import 'dart:async';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:get/get.dart';

class OnlineVideoPlayer extends StatefulWidget {
  const OnlineVideoPlayer({GlobalKey<OnlineVideoPlayerState>? key})
      : super(key: key);
  @override
  State<OnlineVideoPlayer> createState() => OnlineVideoPlayerState();
}

class OnlineVideoPlayerState extends State<OnlineVideoPlayer> {
  final _controller = MeeduPlayerController(
      colorTheme: Colors.red,
      screenManager: const ScreenManager(hideSystemOverlay: false),
      enabledButtons: const EnabledButtons(
          rewindAndfastForward: false, playBackSpeed: false));

  Duration currentPosition = Duration.zero; // to save the video position

  /// subscription to listen the video position changes
  StreamSubscription? _currentPositionSubs;

  @override
  void initState() {
    super.initState();
    Get.find<DashboardController>().setVideoLoadingStatus(false);
    // Listen to the video position changes and save the current position.
    _currentPositionSubs = _controller.onPositionChanged.listen(
      (Duration position) {
        currentPosition = position;
        autoNextTrack();
      },
    );

    // Set the video source after the frame has been rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setDataSource();
    });
  }

  Future autoNextTrack() async {
    final Duration fullLength = _controller.duration.value;
    if (fullLength == currentPosition && fullLength.inSeconds != 0) {
      if (Get.find<DashboardController>().underPlayer?.hasNext ?? false) {
        await Get.find<DashboardController>().underPlayer?.seekToNext();
        await setDataSource(
            index: Get.find<DashboardController>().underPlayer?.currentIndex);
      }
    }
  }

  @override
  void dispose() {
    _currentPositionSubs?.cancel(); // cancel the subscription
    _controller.dispose();
    super.dispose();
  }

  Future<void> setDataSource({int? index}) async {
    // set the data source and play the video in the last video position
    final int currentIndex =
        index ?? Get.find<DashboardController>().underPlayer?.currentIndex ?? 0;
    final String videoUrl = Get.find<DashboardController>()
            .mediaItems[currentIndex]
            .extras?[Values.video] ??
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    await _controller.setDataSource(
      DataSource(
        type: DataSourceType.network,
        source: videoUrl,
      ),
      autoplay: true,
      seekTo: index != null
          ? Duration.zero
          : Get.find<DashboardController>().underPlayer?.position ??
              currentPosition,
    );
  }

  @override
  Widget build(BuildContext context) {
    DashboardController dashboardController = Get.find();
    return SizedBox(
        height: Get.height * 0.32,
        child: GetBuilder<DashboardController>(
          id: "video",
          init: dashboardController,
          builder: (controller) => dashboardController.isVideoLoading.isTrue
              ? const Center(child: ProgressIndicatorButton())
              : AspectRatio(
                  aspectRatio: 16 / 9,
                  child: MeeduVideoPlayer(
                    controller: _controller,
                  ),
                ),
        ));
  }
}
