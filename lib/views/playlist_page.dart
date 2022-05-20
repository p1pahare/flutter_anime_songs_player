import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/cover_for_playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: GetBuilder<PlaylistController>(
        init: PlaylistController(),
        initState: (_) {},
        builder: (_) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                child: TextField(
                  controller: _.playlistName,
                  onChanged: (str) => _.update(),
                  onSubmitted: (str) => _.onCreatePlaylist(),
                  decoration: InputDecoration(
                      hintText: 'Create New Playlist ...',
                      suffixIcon: SizedBox(
                        width: 70,
                        child: Row(
                          children: [
                            if (_.playlistName.text.isNotEmpty)
                              InkWell(
                                  onTap: _.onCreatePlaylist,
                                  child: const Icon(Icons.check_circle)),
                            const SizedBox(
                              width: 20,
                            ),
                            if (_.playlistName.text.isNotEmpty)
                              InkWell(
                                  onTap: _.onClear,
                                  child: const Icon(Icons.cancel_rounded)),
                          ],
                        ),
                      )),
                ),
              ),
              if (_.playlists.isEmpty)
                const Center(child: Text(Values.noResults))
              else
                Expanded(
                  child: ListView.builder(
                      itemCount: _.playlists.length,
                      itemBuilder: ((context, index) => CoverForPlaylist(
                            playlist: _.playlists[index],
                          ))),
                )
            ],
          );
        },
      ),
    );
  }
}
