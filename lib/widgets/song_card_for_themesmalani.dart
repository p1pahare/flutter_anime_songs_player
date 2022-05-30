import 'dart:developer';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SongCardForThemesMalAni extends StatelessWidget {
  const SongCardForThemesMalAni({Key? key, this.themesMalAni, this.themes})
      : super(key: key);
  final ThemesMalAni? themesMalAni;
  final Themes? themes;
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
                          "[${themes!.themeType}] ",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        Expanded(
                          child: Text(
                            themes!.themeName,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    // uncomment in case
                    // themes server adds artists
                    // if (animethemes!.song.artists.isNotEmpty)
                    //   Text(
                    //     "${animethemes!.song.artists.map((e) => e.name).toList()}"
                    //         .replaceAll(RegExp('[^A-Za-z0-9, ]'), ''),
                    //     textAlign: TextAlign.start,
                    //     style: const TextStyle(fontSize: 12),
                    //   ),
                  ],
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
                        ApiResponse apiResponse = await _.webmToMp3(
                            themesMalAni!.malID.toString(),
                            themes!.themeType,
                            themes!.mirror.mirrorURL);
                        await Get.find<DashboardController>().init([
                          AudioEntry(
                              id: themes!.themeName,
                              album: themesMalAni!.name,
                              title: themes!.themeName,
                              url: apiResponse.status
                                  ? apiResponse.data
                                  : themes!.mirror.mirrorURL,
                              urld: '')
                        ]);
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                        child: Icon(Icons.play_circle_fill),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
