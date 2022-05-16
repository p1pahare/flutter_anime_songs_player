import 'package:anime_themes_player/controllers/explore_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplorePage extends GetView<ExploreController> {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.bringCats(reload: true);
    return Container(
      color: Colors.transparent,
      child: controller.obx(
        (state) => ListView.builder(
            controller: controller.scroll,
            itemCount: (state!.length + 1),
            itemBuilder: ((context, index) => index == state.length
                ? const ProgressIndicatorButton()
                : ThemeHolder(cat: state[index]))),

        // here you can put your custom loading indicator, but
        // by default would be Center(child:CircularProgressIndicator())
        onLoading: const Center(child: ProgressIndicatorButton()),
        onEmpty: const Center(child: Text(Values.noResults)),

        // here also you can set your own error widget, but by
        // default will be an Center(child:Text(error))
        onError: (error) => Center(child: Text(error ?? '')),
      ),
    );
  }
}
