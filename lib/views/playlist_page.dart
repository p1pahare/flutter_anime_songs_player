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
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 80,
                  child: Row(
                    children: [
                      BetterButton(
                        icon: Icons.import_export,
                        onPressed: () => _.importFromFile(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _pc.playlistName,
                          onChanged: (str) => _pc.update(),
                          onSubmitted: (str) => _pc.onCreatePlaylist(),
                          decoration: InputDecoration(
                              hintText: 'Create New Playlist ...',
                              suffixIcon: SizedBox(
                                width: 70,
                                child: Row(
                                  children: [
                                    if (_pc.playlistName.text.isNotEmpty)
                                      InkWell(
                                          onTap: _pc.onCreatePlaylist,
                                          child:
                                              const Icon(Icons.check_circle)),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (_pc.playlistName.text.isNotEmpty)
                                      InkWell(
                                          onTap: _pc.onClear,
                                          child:
                                              const Icon(Icons.cancel_rounded)),
                                  ],
                                ),
                              )),
                        ),
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
            );
          },
        ));
  }
}
