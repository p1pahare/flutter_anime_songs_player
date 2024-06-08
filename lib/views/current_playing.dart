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
  bool showSearchBar = false;

  @override
  void didChangeDependencies() {
    audioHeight = Get.height * 0.28;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController _controller = Get.find();
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
            actions: [
              PopupMenuButton<int>(
                onSelected: (optionNumber) =>
                    _onSelected(_controller, optionNumber),
                itemBuilder: (BuildContext context) {
                  return [1, 2, 3].map((int choice) {
                    return PopupMenuItem<int>(
                      value: choice,
                      child: _optionButtons(_controller, choice),
                    );
                  }).toList();
                },
              ),
            ],
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

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSearchBar) _searchBar(_),
              if (!showVideo)
                AnimatedContainer(
                    height: audioHeight,
                    duration: const Duration(seconds: 2),
                    curve: Curves.fastOutSlowIn,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _mediaInfo(_.underPlayer!),
                        Container(
                          alignment: Alignment.bottomRight,
                          width: Get.width * 0.64,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _seekBar(_.underPlayer!),
                              PlayerButtons(
                                _.underPlayer!,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          key: Get.find<GlobalKey<OnlineVideoPlayerState>>(),
                        ),
                        _mediaInfo(_.underPlayer!, noThumb: true),
                        PlayerButtons(
                          _.underPlayer!,
                          videoMode: true,
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ImplicitlyAnimatedReorderableList<MediaItem>(
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
                  shrinkWrap: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBar(DashboardController dashboardController) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 80,
      child: TextField(
        controller: dashboardController.trackName,
        onChanged: (str) => dashboardController.update(),
        onSubmitted: (str) {
          setState(() {
            showSearchBar = false;
          });
        },
        autofocus: true,
        decoration: InputDecoration(
            hintText: 'Search Track ...',
            suffixIcon: SizedBox(
              width: 70,
              child: Row(
                children: [
                  if (dashboardController.trackName.text.isNotEmpty)
                    InkWell(
                        onTap: () {
                          setState(() {
                            showSearchBar = false;
                          });
                        },
                        child: const Icon(Icons.check_circle)),
                  const SizedBox(
                    width: 20,
                  ),
                  if (dashboardController.trackName.text.isNotEmpty)
                    InkWell(
                        onTap: () => dashboardController.trackName.clear(),
                        child: const Icon(Icons.cancel_rounded)),
                ],
              ),
            )),
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
                      borderRadius: BorderRadius.circular(6),
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
                  _controller.playFromPlayer(mediaItem.id);
                  if (showVideo) {
                    Get.find<GlobalKey<OnlineVideoPlayerState>>()
                        .currentState
                        ?.setDataSource(
                            index:
                                _controller.getIndexFromAlbumId(mediaItem.id));
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

  Widget _optionButtons(
      DashboardController dashboardController, int optionNumber) {
    switch (optionNumber) {
      case 1:
        return Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: 35,
              child: Icon(
                Icons.cancel_sharp,
                color: Get.textTheme.bodyMedium!.color,
                size: 20,
              ),
            ),
            Text(
              Values.closePlayer,
              style: TextStyle(
                  color: Get.textTheme.bodyMedium!.color, fontSize: 12),
            )
          ],
        );
      case 2:
        return Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: 35,
              child: Icon(
                !showVideo ? Icons.video_file_sharp : Icons.audio_file_sharp,
                color: Get.textTheme.bodyMedium!.color,
                size: 20,
              ),
            ),
            Text(
              !showVideo ? Values.switchToVideo : Values.switchToAudio,
              style: TextStyle(
                  color: Get.textTheme.bodyMedium!.color, fontSize: 12),
            ),
          ],
        );
      case 3:
        return Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: 35,
              child: Icon(
                Icons.search_outlined,
                color: Get.textTheme.bodyMedium!.color,
                size: 20,
              ),
            ),
            Text(
              Values.search,
              style: TextStyle(
                  color: Get.textTheme.bodyMedium!.color, fontSize: 12),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _onSelected(
      DashboardController dashboardController, int optionNumber) async {
    switch (optionNumber) {
      case 1:
        {
          dashboardController.stopPlayer();
          Get.back();
        }
        break;
      case 2:
        {
          setState(() {
            showVideo = !showVideo;
            audioHeight = Get.height * (showVideo ? 0.42 : 0.28);
          });
          if (showVideo) {
            await dashboardController.underPlayer?.pause();
          } else {
            await dashboardController.underPlayer?.play();
          }
        }
        break;
      case 3:
        {
          setState(() {
            showSearchBar = true;
          });
        }
        break;
      default:
        {}
    }
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

  Widget _mediaInfo(AudioPlayer _audioPlayer, {bool noThumb = false}) {
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
              padding: EdgeInsets.zero,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!noThumb)
                    Container(
                      width: Get.width * 0.38,
                      height: Get.height * 0.28,
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
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _themeTitleAlbumArtist(
                        title: mediaItem.title,
                        album: mediaItem.album,
                        artist: mediaItem.artist),
                  ))
                ],
              ),
            );
          }
        });
  }

  Widget _themeTitleAlbumArtist(
      {String? title, String? album, String? artist}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        if (album != null)
          Text(
            album.toString(),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        if (artist != null)
          Text(
            artist.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 2,
          ),
      ],
    );
  }
}
