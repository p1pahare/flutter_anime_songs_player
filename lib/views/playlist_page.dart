import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistPage extends GetView<PlaylistController> {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.bringCats();
    return Container(
      color: Colors.transparent,
      child: controller.obx(
        (state) => ListView.builder(
            itemCount: state?.length,
            itemBuilder: ((context, index) => ThemeHolder(cat: state?[index]))),

        // here you can put your custom loading indicator, but
        // by default would be Center(child:CircularProgressIndicator())
        onLoading: const Center(child: ProgressIndicatorButton()),
        onEmpty: const Text(Values.noResults),

        // here also you can set your own error widget, but by
        // default will be an Center(child:Text(error))
        onError: (error) => Text(error ?? ''),
      ),
    );
  }
}
