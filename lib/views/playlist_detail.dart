import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/share_playlist.dart';
import 'package:anime_themes_player/widgets/better_icon_button.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_animethemesmain.dart';
// import 'package:anime_themes_player/widgets/theme_holder_for_animethemesmain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistDetail extends StatelessWidget {
  const PlaylistDetail({Key? key, this.playlist}) : super(key: key);
  final Map<int, String>? playlist;
  static const routeName = '/PlaylistPage';
  @override
  Widget build(BuildContext context) {
    List<String> playlist1 = playlist!.values.toList().sublist(2);
    playlist1.removeWhere((element) => element == '0000000');
    Get.find<PlaylistController>().metadataFromThemeId(playlist1);
    return GetBuilder<PlaylistController>(
      id: "detail",
      init: PlaylistController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: AppBar(
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  _.getReadablePlaylistName(playlist?[1] ?? ''),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: Get.theme.iconTheme.color,
                    ),
                    onPressed: () => Get.toNamed(SharePlaylist.routeName,
                        arguments: playlist),
                  )
                ],
              )),
          body: Column(
            children: [
              GetBuilder<DashboardController>(
                  init: DashboardController(),
                  initState: (_) {},
                  builder: (c) {
                    return !c.playerLoaded
                        ? const SizedBox(height: 0)
                        : Container(
                            height: 70,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            child: PlayerCurrent(
                              c.underPlayer!,
                              stopPlayer: c.stopPlayer,
                            ));
                  }),
              SizedBox(
                  height: 50,
                  child: _.listings.length != playlist1.length
                      ? Text(
                          "Downloading Metadata ${_.listings.length + 1} of ${playlist1.length}")
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("${_.listings.length} Themes"),
                              ElevatedButton.icon(
                                  onPressed: () => _.playCurrentListing(),
                                  icon: Icon(
                                    Icons.play_circle,
                                    color: Get.theme.textTheme.bodyText1?.color,
                                  ),
                                  label: const Text(Values.playAll))
                            ],
                          ),
                        )),
              Expanded(
                child: (_.status.isLoading || _.status.isLoadingMore)
                    ? const Center(child: ProgressIndicatorButton())
                    : (_.status.isError)
                        ? Center(child: Text(_.status.errorMessage ?? ''))
                        : (_.status.isSuccess)
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: (_.listings.length),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ThemeHolderForAnimethemesMain(
                                        showOnlyOne: true,
                                        animethemesMain:
                                            AnimethemesMain.fromJson(_
                                                .listings[index]['animetheme']),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: BetterButton(
                                          onPressed: () {
                                            playlist1.remove(_.listings[index]
                                                    ['id']
                                                .toString()
                                                .padLeft(7, '0'));
                                            _.deleteFromPlayList(
                                                playlist![0].toString(),
                                                _.listings[index]['id']
                                                    .toString());
                                          },
                                          icon: Icons.cancel_rounded,
                                        ),
                                      ),
                                    ],
                                  );
                                })
                            : (_.status.isEmpty)
                                ? const Center(child: Text(Values.noResults))
                                : const SizedBox(height: 0),
              )
            ],
          ),
        );
      },
    );
  }
}
