import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/views/online_video_player.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons(this._audioPlayer, {Key? key, this.videoMode = false})
      : super(key: key);
  final AudioPlayer _audioPlayer;
  final bool videoMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StreamBuilder<bool>(
                stream: _audioPlayer.shuffleModeEnabledStream,
                builder: (context, snapshot) {
                  return _shuffleButton(context, snapshot.data ?? false);
                },
              ),
              StreamBuilder<SequenceState?>(
                stream: _audioPlayer.sequenceStateStream,
                builder: (_, __) {
                  return _previousButton();
                },
              ),
              if (!videoMode)
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (_, snapshot) {
                    final playerState = snapshot.data;
                    if (playerState == null) {
                      return const SizedBox(
                        height: 0,
                        width: 0,
                      );
                    } else {
                      return _playPauseButton(playerState);
                    }
                  },
                ),
              StreamBuilder<SequenceState?>(
                stream: _audioPlayer.sequenceStateStream,
                builder: (_, __) {
                  return _nextButton();
                },
              ),
              StreamBuilder<LoopMode>(
                stream: _audioPlayer.loopModeStream,
                builder: (context, snapshot) {
                  return _repeatButton(context, snapshot.data ?? LoopMode.off);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: 25.0,
        height: 25.0,
        child: const ProgressIndicatorButton(
          radius: 12,
        ),
      );
    } else if (_audioPlayer.playing != true) {
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        iconSize: 38.0,
        onPressed: _audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.pause),
        iconSize: 38.0,
        onPressed: _audioPlayer.pause,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.replay),
        iconSize: 38.0,
        onPressed: () => _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.effectiveIndices?.first),
      );
    }
  }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? const Icon(
              Icons.shuffle_on_rounded,
            )
          : const Icon(Icons.shuffle_rounded),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await _audioPlayer.shuffle();
        }
        await _audioPlayer.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _previousButton() {
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: () async {
        if (_audioPlayer.hasPrevious) {
          if (videoMode) {
            Get.find<GlobalKey<OnlineVideoPlayerState>>().currentState?.pause();
            Get.find<DashboardController>().setVideoLoadingStatus(true);
          }
          await _audioPlayer.seekToPrevious();
          if (videoMode) {
            await Get.find<GlobalKey<OnlineVideoPlayerState>>()
                .currentState
                ?.setDataSource(index: _audioPlayer.currentIndex);
            Get.find<GlobalKey<OnlineVideoPlayerState>>().currentState?.play();
            Get.find<DashboardController>().setVideoLoadingStatus(false);
          }
        }
      },
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: () async {
        if (_audioPlayer.hasNext) {
          if (videoMode) {
            Get.find<GlobalKey<OnlineVideoPlayerState>>().currentState?.pause();
            Get.find<DashboardController>().setVideoLoadingStatus(true);
          }
          await _audioPlayer.seekToNext();
          if (videoMode) {
            await Get.find<GlobalKey<OnlineVideoPlayerState>>()
                .currentState
                ?.setDataSource(index: _audioPlayer.currentIndex);
            Get.find<GlobalKey<OnlineVideoPlayerState>>().currentState?.play();
            Get.find<DashboardController>().setVideoLoadingStatus(false);
          }
        }
      },
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      const Icon(
        Icons.repeat_rounded,
      ),
      const Icon(
        Icons.repeat_on_rounded,
      ),
      const Icon(Icons.repeat_one_on_rounded),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        _audioPlayer.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }
}
