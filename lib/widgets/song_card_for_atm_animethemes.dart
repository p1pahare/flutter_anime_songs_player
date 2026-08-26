import 'dart:developer';
import 'dart:io';

import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlists_controller.dart';
import 'package:anime_themes_player/controllers/search_controller.dart' as sc;
import 'package:anime_themes_player/controllers/users_controller.dart';
import 'package:anime_themes_player/models/anime.dart' as animemain;
import 'package:anime_themes_player/models/animethemes.dart';
import 'package:anime_themes_player/models/playlist_songs_response.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SongCardForAtmAnimethemes extends StatelessWidget {
  const SongCardForAtmAnimethemes(
      {Key? key, this.animethemesMain, this.animethemeentries})
      : super(key: key);
  final Animethemes? animethemesMain;
  final AtmAnimethemeentries? animethemeentries;

  @override
  Widget build(BuildContext context) {
    String versioninfo =
        "[${animethemesMain!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}] ";

    return SizedBox(
      width: context.width - 50,
      child: Card(
        elevation: 3.5,
        color: Theme.of(context).cardColor,
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
                  width: context.width * 0.26,
                  child: Image.network(
                    animethemesMain?.anime.images.first.link ?? Values.noImage,
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
                      Flexible(
                        child: Text(
                          "${animethemesMain!.song.artists.map((e) => e.name).toList()}"
                              .replaceAll(RegExp('[^A-Za-z0-9, ]'), ''),
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                  onTap: () async {
                    final usersController = Get.find<UsersController>();
                    final playlistController = Get.find<PlaylistsController>();
                    final isLoggedIn =
                        usersController.mode.value == LoginMode.loggedIn;
                    final options = <int, String>{
                      0: 'Add to Current Queue',
                    };

                    if (isLoggedIn) {
                      playlistController.hydratePlaylistsFromCache();
                      await playlistController.fetchPlaylists();
                      for (int index = 0;
                          index < playlistController.playlistList.length;
                          index++) {
                        options[index + 1] =
                            playlistController.playlistList[index].name;
                      }
                    } else {
                      options[1] = 'Login to Add Theme';
                    }

                    int? selectedOption = await showOptions(options: options);
                    log("Selected Option is $selectedOption");
                    if (selectedOption == null) return;
                    if (animethemeentries == null || animethemesMain == null) {
                      showMessage("Something went wrong");
                      return;
                    }

                    if (selectedOption == 0) {
                      await Get.find<DashboardController>().init(
                        [
                          PlaylistSongTrack.queue(
                            id: animethemesMain!.id.toString(),
                            videoId: animethemeentries!.videos.first.id ?? 0,
                            audioUrl: animethemeentries!.videos.first.audio.link,
                            videoUrl: animethemeentries!.videos.first.link,
                            album: animethemesMain!.anime.name,
                            title: animethemesMain!.song.title,
                            artist: animethemesMain!.song.artists
                                .map((artst) => artst.name)
                                .join(","),
                            coverUrl: animethemesMain!.anime.images.isEmpty
                                ? null
                                : animethemesMain!.anime.images.first.link,
                          )
                        ],
                        addToQueueOnly: true,
                      );
                    } else if (isLoggedIn) {
                      final playlistIndex = selectedOption - 1;
                      final videoId = animethemeentries!.videos.first.id;
                      final entryId = animethemeentries!.id;
                      if (playlistIndex < 0 ||
                          playlistIndex >= playlistController.playlistList.length ||
                          videoId == null ||
                          entryId <= 0) {
                        showMessage("Something went wrong");
                        return;
                      }

                      final response = await playlistController.addTrackToPlaylist(
                        playlistId:
                            playlistController.playlistList[playlistIndex].id,
                        videoId: videoId,
                        entryId: entryId,
                      );
                      showMessage(response.message);
                    } else if (selectedOption == 1) {
                      await usersController.setMode(LoginMode.login);
                      Get.find<DashboardController>().updateIndex(2);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                    child: Icon(
                      Icons.playlist_add,
                    ),
                  )),
              GetBuilder<sc.SearchController>(
                  init: sc.SearchController(),
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
                          String audioUrl =
                              animethemeentries!.videos.first.audio.link;
                          final videoUrl = animethemeentries!.videos.first.link;
                          log(audioUrl);
                          if (Platform.isIOS || Platform.isMacOS) {
                            animemain.Anime? animeMain = await _
                                .slugToMalId(animethemesMain!.anime.slug);
                            if (animeMain != null) {
                              audioUrl = (await _.webmToMp3(
                                      animeMain.resources.first.externalId
                                          .toString(),
                                      "${animethemesMain?.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}",
                                      animethemeentries!.videos.first.link))
                                  .data as String;
                            }
                          }
                          await Get.find<DashboardController>().init([
                            PlaylistSongTrack.queue(
                              id: animethemesMain!.id.toString(),
                              videoId: animethemeentries!.videos.first.id ?? 0,
                              audioUrl: audioUrl,
                              videoUrl: videoUrl,
                              album: animethemesMain!.anime.name,
                              title: animethemesMain!.song.title,
                              artist: animethemesMain!.song.artists
                                  .map((artst) => artst.name)
                                  .join(","),
                              coverUrl: animethemesMain!.anime.images.isEmpty
                                  ? null
                                  : animethemesMain!.anime.images.first.link,
                            )
                          ]);
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
