import 'dart:developer';

import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/models/anime_main.dart' as animemain;
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SongCardForAnimethemesMain extends StatelessWidget {
  const SongCardForAnimethemesMain(
      {Key? key, this.animethemesMain, this.animethemeentries})
      : super(key: key);
  final AnimethemesMain? animethemesMain;
  final Animethemeentries? animethemeentries;

  @override
  Widget build(BuildContext context) {
    String versioninfo =
        "[${animethemesMain!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}] ";

    return SizedBox(
      width: Get.width - 50,
      child: Card(
        elevation: 3.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: () {},
          child: Row(
            children: [
              Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7))),
                  width: Get.width * 0.26,
                  child: Image.network(
                    animethemesMain?.anime.images.first.link ??
                        Values.errorImage,
                    height: 95,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProcess) =>
                        loadingProcess == null
                            ? child
                            : const ProgressIndicatorButton(),
                    cacheHeight: 160,
                    cacheWidth: 160,
                  )),
              Container(
                width: 0.3333,
                height: 95,
                margin: const EdgeInsets.only(right: 20),
                color: Colors.brown,
              ),
              Expanded(
                child: SizedBox(
                  height: 95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        versioninfo + animethemesMain!.song.title,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "${animethemesMain!.anime.season} ${animethemesMain!.anime.year}",
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      Text(
                        "${animethemesMain!.song.artists.map((e) => e.name).toList()}"
                            .replaceAll(RegExp('[^A-Za-z0-9, ]'), ''),
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                  onTap: () {},
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
                          animemain.AnimeMain? animeMain =
                              await _.slugToMalId(animethemesMain!.anime.slug);

                          log("${animethemesMain?.anime.slug} malId ${animeMain?.resources.first.externalId} themeId ${animethemesMain?.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'} ${animethemeentries!.videos.first.link}");

                          ApiResponse apiResponse;
                          if (animeMain != null) {
                            apiResponse = await _.webmToMp3(
                                animeMain.resources.first.externalId.toString(),
                                "${animethemesMain!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}",
                                animethemeentries!.videos.first.link);
                          } else {
                            apiResponse = ApiResponse(
                                status: false,
                                message: "failed to fetch Anime");
                          }
                          await Get.find<DashboardController>().init(AudioEntry(
                              album: animethemesMain!.anime.name,
                              title: animethemesMain!.song.title,
                              url: apiResponse.status
                                  ? apiResponse.data
                                  : animethemeentries!.videos.first.link,
                              urld: animethemesMain!.anime.images.isEmpty
                                  ? ''
                                  : animethemesMain!.anime.images.first.link));
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
