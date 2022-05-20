import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistDetail extends StatelessWidget {
  const PlaylistDetail({Key? key, this.playlist}) : super(key: key);
  final Map<int, String>? playlist;
  static const routeName = '/PlaylistPage';
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlaylistController>(
      init: PlaylistController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _.getReadablePlaylistName(playlist?[1] ?? ''),
            ),
          ),
          body: ListView.builder(
            itemCount: playlist?.values.length,
            itemBuilder: (context, index) {
              if (index < 2 || playlist?.values.elementAt(index) == '0000000') {
                return const SizedBox(
                  height: 0,
                );
              }
              return Text(playlist?.values.elementAt(index) ?? '');
            },
          ),
        );
      },
    );
  }
}
