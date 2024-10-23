import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/better_icon_button.dart';
import 'package:anime_themes_player/widgets/cover_for_playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlaylistController _pc = Get.find();
    return Container(
        color: Colors.transparent,
        child: GetBuilder<PlaylistController>(
          init: PlaylistController(),
          initState: (_) {},
          builder: (_) {
            return GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: 80,
                    child: Row(
                      children: [
                        BetterButton(
                          icon: Icons.arrow_circle_up_rounded,
                          onPressed: () {},
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        BetterButton(
                          icon: Icons.add_circle_outline_rounded,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  if (_pc.playlists.isEmpty)
                    const Center(child: Text(Values.noResults))
                  else
                    Expanded(
                      child: ListView.builder(
                          itemCount: _pc.playlists.length,
                          itemBuilder: ((context, index) => CoverForPlaylist(
                                playlist: _pc.playlists[index],
                                playlistIndex: index,
                              ))),
                    )
                ],
              ),
            );
          },
        ));
  }
}
