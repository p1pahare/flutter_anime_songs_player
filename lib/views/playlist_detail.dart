import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistDetail extends StatelessWidget {
  const PlaylistDetail({Key? key}) : super(key: key);
  static const routeName = '/PlaylistPage';
  @override
  Widget build(BuildContext context) {
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
                title: const Text(
                  "Play List NAME ",
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_circle_down_rounded,
                      color: Get.theme.iconTheme.color,
                    ),
                    onPressed: () {},
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
              Expanded(
                child: Container(),
              )
            ],
          ),
        );
      },
    );
  }
}
