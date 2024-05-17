import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/views/current_playing.dart';
import 'package:anime_themes_player/widgets/better_icon_button.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PlayerCurrent extends StatelessWidget {
  const PlayerCurrent(this._audioPlayer, {Key? key, @required this.stopPlayer})
      : super(key: key);
  final VoidCallback? stopPlayer;
  final AudioPlayer _audioPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
        stream: _audioPlayer.currentIndexStream,
        builder: (context, indexShot) {
          if (!indexShot.hasData || indexShot.data == null) {
            return const SizedBox(
              width: 0,
            );
          } else {
            final AudioSource? _currentSource = Get.find<DashboardController>()
                .currentAudioSource(indexShot.data ?? -1);
            if (_currentSource == null) {
              return const SizedBox(
                width: 0,
              );
            }
            final mediaItem = _currentSource.sequence.first.tag as MediaItem;
            return GestureDetector(
              onTap: () {
                Get.toNamed(CurrentPlaying.routeName);
              },
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          mediaItem.artUri.toString(),
                        ),
                        fit: BoxFit.cover,
                      )),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(mediaItem.title),
                                  Text(
                                    mediaItem.album.toString(),
                                    overflow: TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                            _closeButton(),
                            _playButton(),
                          ],
                        ),
                      ),
                      Container(
                        height: 0.3,
                        color: Get.theme.appBarTheme.backgroundColor,
                      ),
                      Container(
                        color: Get.theme.appBarTheme.backgroundColor,
                        child: StreamBuilder<Duration?>(
                          stream: _audioPlayer.durationStream,
                          builder: (_, fullDurationSnap) {
                            final fullDuration = fullDurationSnap.data;

                            if (fullDuration == null) {
                              return const SizedBox(
                                height: 0,
                                width: 0,
                              );
                            } else {
                              return StreamBuilder<Duration>(
                                  stream: _audioPlayer.positionStream,
                                  builder: (context, currentDurationSnap) {
                                    final currentDuration =
                                        currentDurationSnap.data;
                                    // log("${currentDuration?.inSeconds} ${fullDuration.inSeconds}");

                                    if (currentDuration == null) {
                                      return const SizedBox(
                                        height: 0,
                                        width: 0,
                                      );
                                    } else {
                                      return Slider(
                                          value: currentDuration.inSeconds >
                                                  fullDuration.inSeconds
                                              ? fullDuration.inSeconds
                                                  .toDouble()
                                              : currentDuration.inSeconds
                                                  .toDouble(),
                                          max:
                                              fullDuration.inSeconds.toDouble(),
                                          onChanged: (val) {
                                            _audioPlayer.seek(
                                                Duration(seconds: val.toInt()));
                                          });
                                    }
                                  });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            );
          }
        });
  }

  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 16.0,
        height: 16.0,
        child: const ProgressIndicatorButton(
          radius: 8,
        ),
      );
    } else if (_audioPlayer.playing != true) {
      return BetterButton(
        icon: Icons.play_arrow,
        onPressed: _audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return BetterButton(
        icon: Icons.pause,
        onPressed: _audioPlayer.pause,
      );
    } else {
      return BetterButton(
        icon: Icons.replay,
        onPressed: () => _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.effectiveIndices?.first),
      );
    }
  }

  Widget _playButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: StreamBuilder<PlayerState>(
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
    );
  }

  Widget _closeButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: BetterButton(icon: Icons.cancel_sharp, onPressed: stopPlayer),
    );
  }
}
