import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/player_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class CurrentPlaying extends StatelessWidget {
  const CurrentPlaying({Key? key}) : super(key: key);
  static const routeName = '/CurrentlyPlaying';
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
          if (_.underPlayer == null) {
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
            children: [
              _closeButton(_.stopPlayer),
              _mediaInfo(_.underPlayer!),
              _seekBar(_.underPlayer!),
              PlayerButtons(
                _.underPlayer!,
              )
            ],
          );
        },
      ),
    );
  }

  Widget _closeButton(VoidCallback onClose) {
    return TextButton.icon(
      icon: Icon(Icons.cancel_sharp, color: Get.textTheme.bodyText1!.color),
      onPressed: onClose,
      label: Text(
        Values.closePlayer,
        style: TextStyle(color: Get.textTheme.bodyText1!.color),
      ),
    );
  }

  Widget _seekBar(AudioPlayer _audioPlayer) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
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

  Widget _mediaInfo(AudioPlayer _audioPlayer) {
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
            return Column(
              children: [
                Container(
                  width: Get.width * 0.6,
                  height: Get.width * 0.8,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: NetworkImage(
                      mediaItem.artUri.toString(),
                    ),
                    fit: BoxFit.cover,
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
            );
          }
        });
  }
}
