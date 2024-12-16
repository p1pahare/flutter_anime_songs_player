import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
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
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: mediaItem.artUri.toString(),
                    fit: BoxFit.fill,
                    height: double.infinity,
                    width: 100,
                    alignment: Alignment.center,
                    placeholder: (context, child) =>
                        const ProgressIndicatorButton(),
                    errorWidget: (context, url, error) => Image.asset(
                      Values.noImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 100,
                          ),
                          Expanded(
                            child: Container(
                              color:
                                  (Get.isDarkMode ? Colors.black : Colors.white)
                                      .withOpacity(0.75),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 5),
                                    child: Text(
                                      Values.nowPlaying,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Get.textTheme.headlineSmall?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  Container(
                                    height: 70,
                                    color:
                                        Get.theme.appBarTheme.backgroundColor,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          context.width * 0.45,
                                                      child: Text(
                                                        mediaItem.artist
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Get
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                                fontSize: 11),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                    Text(
                                                      mediaItem.title,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Get
                                                          .textTheme.bodyLarge,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 5, 5, 5),
                                          child: StreamBuilder<Duration?>(
                                            stream: _audioPlayer.durationStream,
                                            builder: (_, fullDurationSnap) {
                                              final fullDuration =
                                                  fullDurationSnap.data;

                                              if (fullDuration == null) {
                                                return const SizedBox(
                                                  height: 0,
                                                  width: 0,
                                                );
                                              } else {
                                                return StreamBuilder<Duration>(
                                                    stream: _audioPlayer
                                                        .positionStream,
                                                    builder: (context,
                                                        currentDurationSnap) {
                                                      final currentDuration =
                                                          currentDurationSnap
                                                              .data;

                                                      if (currentDuration ==
                                                          null) {
                                                        return const SizedBox(
                                                          height: 0,
                                                          width: 0,
                                                        );
                                                      } else {
                                                        return Slider(
                                                            value: currentDuration
                                                                        .inSeconds >
                                                                    fullDuration
                                                                        .inSeconds
                                                                ? fullDuration
                                                                    .inSeconds
                                                                    .toDouble()
                                                                : currentDuration
                                                                    .inSeconds
                                                                    .toDouble(),
                                                            max: fullDuration
                                                                .inSeconds
                                                                .toDouble(),
                                                            onChanged: (val) {
                                                              _audioPlayer.seek(
                                                                  Duration(
                                                                      seconds: val
                                                                          .toInt()));
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
                                ],
                              ),
                            ),
                          )
                        ]),
                  ),
                  Positioned(
                    top: 5,
                    right: 10,
                    child: _closeButton(),
                  ),
                  Positioned(
                    top: 5,
                    right: 55,
                    child: _playButton(),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return BetterButton(
        alternate: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          width: 24.0,
          height: 24.0,
          alignment: Alignment.center,
          child: const ProgressIndicatorButton(
            radius: 8,
          ),
        ),
        onPressed: () {},
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
