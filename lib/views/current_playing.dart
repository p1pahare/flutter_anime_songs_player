import 'dart:ui';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/online_video_player.dart';
import 'package:anime_themes_player/widgets/better_icon_button.dart';
import 'package:anime_themes_player/widgets/player_buttons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide ReorderableList;

import 'package:get/get.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class CurrentPlaying extends StatefulWidget {
  const CurrentPlaying({Key? key}) : super(key: key);
  static const routeName = '/CurrentlyPlaying';

  @override
  State<CurrentPlaying> createState() => _CurrentPlayingState();
}

class _CurrentPlayingState extends State<CurrentPlaying> {
  double audioHeight = 0;
  bool showVideo = false;

  @override
  void didChangeDependencies() {
    audioHeight = Get.height * 0.5;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: const Text(Values.currentlyPlaying),
          ),
          preferredSize: const Size.fromHeight(40)),
      body: GetBuilder<DashboardController>(
        init: DashboardController(),
        initState: (_) {},
        builder: (_) {
          if (!_.playerLoaded) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  Values.noThemesBeingPlayed,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _optionButtons(_),
                if (!showVideo)
                  AnimatedContainer(
                      height: audioHeight,
                      duration: const Duration(seconds: 2),
                      curve: Curves.fastOutSlowIn,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _mediaInfo(_.underPlayer!),
                            _seekBar(_.underPlayer!),
                            PlayerButtons(
                              _.underPlayer!,
                            ),
                          ],
                        ),
                      )),
                if (showVideo)
                  AnimatedContainer(
                      height: audioHeight,
                      duration: const Duration(seconds: 2),
                      curve: Curves.fastOutSlowIn,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            OnlineVideoPlayer(
                              key:
                                  Get.find<GlobalKey<OnlineVideoPlayerState>>(),
                            ),
                            _mediaInfo(_.underPlayer!, withoutImage: true),
                            PlayerButtons(
                              _.underPlayer!,
                              videoMode: true,
                            ),
                          ],
                        ),
                      )),
                ImplicitlyAnimatedReorderableList<MediaItem>(
                  items: _.mediaItems,
                  areItemsTheSame: (oldItem, newItem) =>
                      oldItem.id == newItem.id,
                  onReorderFinished: (item, from, to, newItems) {
                    // Remember to update the underlying data when the list has been
                    // reordered.
                    _.mediaItems.removeAt(from);
                    _.mediaItems.insert(to, item);
                  },
                  itemBuilder: (context, itemAnimation, item, index) {
                    // Each item must be wrapped in a Reorderable widget.
                    return Reorderable(
                      // Each item must have an unique key.
                      key: ValueKey(item),
                      // The animation of the Reorderable builder can be used to
                      // change to appearance of the item between dragged and normal
                      // state. For example to add elevation when the item is being dragged.
                      // This is not to be confused with the animation of the itemBuilder.
                      // Implicit animations (like AnimatedContainer) are sadly not yet supported.
                      builder: (context, dragAnimation, inDrag) {
                        final t = dragAnimation.value;
                        final elevation = lerpDouble(0, 8, t);
                        final color = Color.lerp(
                            Colors.white, Colors.white.withOpacity(0.8), t);

                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: itemAnimation,
                          child: Material(
                            key: Key(item.id),
                            color: color,
                            elevation: elevation ?? 1.0,
                            type: MaterialType.transparency,
                            child: _mediaInfoFromMediaItem(item, index, _),
                          ),
                        );
                      },
                    );
                  },
                  shrinkWrap: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mediaInfoFromMediaItem(
      MediaItem mediaItem, int index, DashboardController _controller) {
    return Material(
      key: ValueKey(mediaItem.id),
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              onTap: () {},
              leading: Handle(
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      mediaItem.artUri.toString(),
                    ),
                    fit: BoxFit.cover,
                  )),
                ),
              ),
              title: Text(mediaItem.title),
              subtitle: Text(mediaItem.album.toString()),
              trailing: BetterButton(
                icon: Icons.play_circle_rounded,
                onPressed: () async {
                  await _controller.playFromPlayer(index);
                  if (showVideo) {
                    Get.find<GlobalKey<OnlineVideoPlayerState>>()
                        .currentState
                        ?.setDataSource(index: index);
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: BetterButton(
              icon: Icons.cancel_rounded,
              onPressed: () {
                _controller.removeThemeFromPlayer(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionButtons(DashboardController dashboardController) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
            icon: Icon(
              Icons.cancel_sharp,
              color: Get.textTheme.bodyMedium!.color,
              size: 20,
            ),
            onPressed: dashboardController.stopPlayer,
            label: Text(
              Values.closePlayer,
              style: TextStyle(
                  color: Get.textTheme.bodyMedium!.color, fontSize: 12),
            ),
          ),
          TextButton.icon(
            icon: Icon(
              !showVideo ? Icons.video_file_sharp : Icons.audio_file_sharp,
              color: Get.textTheme.bodyMedium!.color,
              size: 20,
            ),
            onPressed: () async {
              setState(() {
                showVideo = !showVideo;
              });
              if (showVideo) {
                await dashboardController.underPlayer?.pause();
              } else {
                await dashboardController.underPlayer?.seek(
                    Get.find<GlobalKey<OnlineVideoPlayerState>>()
                        .currentState
                        ?.currentPosition);
                await dashboardController.underPlayer?.play();
              }
            },
            label: Text(
              !showVideo ? Values.switchToVideo : Values.switchToAudio,
              style: TextStyle(
                  color: Get.textTheme.bodyMedium!.color, fontSize: 12),
            ),
          ),
          TextButton.icon(
            icon: Icon(
              audioHeight == 0
                  ? Icons.circle_outlined
                  : Icons.hide_source_sharp,
              color: Get.textTheme.bodyMedium!.color,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                if (audioHeight == 0) {
                  audioHeight = Get.height * 0.5;
                } else {
                  audioHeight = 0;
                }
              });
            },
            label: Text(
              audioHeight == 0 ? Values.showPlayer : Values.hidePlayer,
              style: TextStyle(
                  color: Get.textTheme.bodyMedium!.color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seekBar(AudioPlayer _audioPlayer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
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
                  final currentDuration = currentDurationSnap.data;
                  // log("${currentDuration?.inSeconds} ${fullDuration.inSeconds}");

                  if (currentDuration == null) {
                    return const SizedBox(
                      height: 0,
                      width: 0,
                    );
                  } else {
                    return Slider(
                        value:
                            currentDuration.inSeconds > fullDuration.inSeconds
                                ? fullDuration.inSeconds.toDouble()
                                : currentDuration.inSeconds.toDouble(),
                        max: fullDuration.inSeconds.toDouble(),
                        onChanged: (val) {
                          _audioPlayer.seek(Duration(seconds: val.toInt()));
                        });
                  }
                });
          }
        },
      ),
    );
  }

  Widget _mediaInfo(AudioPlayer _audioPlayer, {bool withoutImage = false}) {
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
            return Padding(
              padding:
                  withoutImage ? const EdgeInsets.all(16.0) : EdgeInsets.zero,
              child: Column(
                children: [
                  if (!withoutImage)
                    Container(
                      width: Get.width * 0.85,
                      height: Get.width * 0.65,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          mediaItem.artUri.toString(),
                        ),
                        fit: BoxFit.fill,
                      )),
                    ),
                  Text(
                    mediaItem.title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    mediaItem.album.toString(),
                    maxLines: 2,
                  ),
                ],
              ),
            );
          }
        });
  }
}
