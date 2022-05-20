import 'package:anime_themes_player/controllers/explore_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_animemain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplorePage extends GetView<ExploreController> {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.searchListings();
    return SizedBox(
      height: Get.height,
      child: Center(
        child: SingleChildScrollView(
          controller: controller.scroll,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 130,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GetBuilder<ExploreController>(
                  init: ExploreController(),
                  initState: (_) {},
                  builder: (_) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<int>(
                            value: _.seasonValue,
                            items: _.seasonValuesMap.entries
                                .map<DropdownMenuItem<int>>(
                                    (entry) => DropdownMenuItem(
                                          value: entry.key,
                                          child: Text(entry.value),
                                        ))
                                .toList(),
                            onChanged: _.changeseasonValue),
                        DropdownButton<int>(
                            value: _.yearValue,
                            items: _.yearValuesMap.entries
                                .map<DropdownMenuItem<int>>(
                                    (entry) => DropdownMenuItem(
                                          value: entry.key,
                                          child: Text(entry.value.toString()),
                                        ))
                                .toList(),
                            onChanged: _.changeyearValue)
                      ],
                    );
                  },
                ),
              ),
              // if (controller.listings.isNotEmpty)
              controller.obx(
                (state) => ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (state!.length),
                    itemBuilder: (context, index) {
                      return ThemeHolderForAnimeMain(
                        animeMain: state[index],
                      );
                    }),

                // here you can put your custom loading indicator, but
                // by default would be Center(child:CircularProgressIndicator())
                onLoading: const Center(child: ProgressIndicatorButton()),
                onEmpty: const Center(child: Text(Values.noResults)),

                // here also you can set your own error widget, but by
                // default will be an Center(child:Text(error))
                onError: (error) => Center(child: Text(error ?? '')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
