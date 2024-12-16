import 'package:anime_themes_player/views/playlist_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/playlist_controller.dart';

class CoverForPlaylist extends StatelessWidget {
  const CoverForPlaylist({Key? key, this.playlist, required this.playlistIndex})
      : super(key: key);
  final Map<int, String>? playlist;
  final int playlistIndex;
  @override
  Widget build(BuildContext context) {
    PlaylistController _pc = Get.find();

    return Card(
        elevation: 3.5,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          onTap: () {
            Get.toNamed(PlaylistDetail.routeName,
                arguments: [playlistIndex, playlist]);
          },
          title: const Text("track name"),
          subtitle: const Text("0 Songs"),
          trailing: IconButton(
              onPressed: () {}, icon: const Icon(Icons.cancel_outlined)),
        ));
  }
}
