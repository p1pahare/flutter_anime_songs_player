import 'package:anime_themes_player/views/playlist_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/playlist_controller.dart';

class CoverForPlaylist extends StatelessWidget {
  const CoverForPlaylist({Key? key, this.playlist}) : super(key: key);
  final Map<int, String>? playlist;
  @override
  Widget build(BuildContext context) {
    PlaylistController _pc = Get.find();

    return Card(
        elevation: 3.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          onTap: () {
            Get.toNamed(PlaylistDetail.routeName, arguments: playlist);
          },
          title: Text(_pc.getReadablePlaylistName(playlist?[1] ?? '')),
          subtitle: Text(_pc.songCount(playlist!)),
          trailing: IconButton(
              onPressed: () => _pc.deletePlayList(playlist!),
              icon: const Icon(Icons.cancel_outlined)),
        ));
  }
}
