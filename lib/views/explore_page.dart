import 'package:anime_themes_player/controllers/explore_controller.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplorePage extends GetView<ExploreController> {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.bringCats();
    return Container(
      color: Colors.transparent,
      child: controller.obx(
        (state) => const Text("state.length"),

        // here you can put your custom loading indicator, but
        // by default would be Center(child:CircularProgressIndicator())
        onLoading: const Center(child: ProgressIndicatorButton()),
        onEmpty: const Text('No data found'),

        // here also you can set your own error widget, but by
        // default will be an Center(child:Text(error))
        onError: (error) => const Text("error"),
      ),
    );
  }
}
