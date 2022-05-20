import 'dart:developer';

import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SongCardForAnimethemes extends StatelessWidget {
  const SongCardForAnimethemes(
      {Key? key, this.animethemes, this.animethemeentries, this.animeMain})
      : super(key: key);
  final AnimeMain? animeMain;
  final Animethemes? animethemes;
  final Animethemeentries? animethemeentries;
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => log("message"),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).textTheme.bodyText1!.color!)),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "[${animethemes!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}] ",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        if (animethemes!.song != null)
                          Expanded(
                            child: Text(
                              animethemes!.song!.title,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                      ],
                    ),
                    if (animethemes!.song != null &&
                        animethemes!.song!.artists.isNotEmpty)
                      Text(
                        "${animethemes!.song!.artists.map((e) => e.name).toList()}"
                            .replaceAll(RegExp('[^A-Za-z0-9, ]'), ''),
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              InkWell(
                  onTap: () async {
                    PlaylistController _pc = Get.find<PlaylistController>();
                    List<Map<int, String>> playlists = _pc.playlists;
                    int? selectedOption = await showOptions(options: {
                      0: 'Add to Current Queue',
                      for (int i = 1; i <= playlists.length; i++)
                        i: _pc
                            .getReadablePlaylistName(playlists[i - 1][1] ?? '')
                    });
                    log("Selected Option is $selectedOption");
                    if (selectedOption == null) return;
                    if (selectedOption == 0) {
                      log("malId ${animeMain!.resources.first.externalId} themeId ${animethemes!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'} ${animethemeentries!.videos.first.link}");
                      ApiResponse apiResponse =
                          await Get.find<SearchController>().webmToMp3(
                              animeMain!.resources.first.externalId.toString(),
                              "${animethemes!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}",
                              animethemeentries!.videos.first.link);
                      await Get.find<DashboardController>().init(
                          AudioEntry(
                              album: animeMain!.name,
                              title: animethemes!.song?.title ?? '',
                              url: apiResponse.status
                                  ? apiResponse.data
                                  : animethemeentries!.videos.first.link,
                              urld: animeMain!.images.isEmpty
                                  ? ''
                                  : animeMain!.images.first.link),
                          addToQueueOnly: true);
                    } else {
                      _pc.addToPlayList(playlists[selectedOption - 1][0] ?? '',
                          animethemes?.id.toString() ?? '');
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                    child: Icon(
                      Icons.playlist_add,
                    ),
                  )),
              GetBuilder<SearchController>(
                  init: SearchController(),
                  initState: (_) {},
                  builder: (_) {
                    if (_.loadingSong) {
                      return const SizedBox(
                          height: 24,
                          width: 24,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ProgressIndicatorButton(
                              radius: 7,
                            ),
                          ));
                    }
                    return InkWell(
                        onTap: () async {
                          log("malId ${animeMain!.resources.first.externalId} themeId ${animethemes!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'} ${animethemeentries!.videos.first.link}");
                          ApiResponse apiResponse = await _.webmToMp3(
                              animeMain!.resources.first.externalId.toString(),
                              "${animethemes!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}",
                              animethemeentries!.videos.first.link);
                          await Get.find<DashboardController>().init(AudioEntry(
                              album: animeMain!.name,
                              title: animethemes!.song?.title ?? '',
                              url: apiResponse.status
                                  ? apiResponse.data
                                  : animethemeentries!.videos.first.link,
                              urld: animeMain!.images.isEmpty
                                  ? ''
                                  : animeMain!.images.first.link));
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8),
                          child: Icon(Icons.play_circle_fill),
                        ));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
