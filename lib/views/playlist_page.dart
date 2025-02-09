import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/views/playlist_forms_page.dart';
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
          init: _pc,
          initState: (_) {},
          builder: (_) {
            if (_.mode.value == LoginMode.loggedIn) {
              return Container(
                color: Colors.pink,
              );
            }
            return PlaylistFormsPage(pc: _pc);
          },
        ));
  }
}
