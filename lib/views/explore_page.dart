import 'dart:developer';

import 'package:anime_themes_player/controllers/explore_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/cover_for_anime.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/text_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExploreController>();
    return SizedBox(
      height: context.height,
      child: SingleChildScrollView(
        controller: controller.scroll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 130,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GetBuilder<ExploreController>(
                init: controller,
                initState: (_) {
                  controller.searchListings();
                },
                builder: (_) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: Get.size.width * 0.32,
                        child: DropdownButtonFormField<int>(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            decoration: getOldTextFieldDecoration(context, ""),
                            value: _.seasonValue,
                            items: _.seasonValuesMap.entries
                                .map<DropdownMenuItem<int>>(
                                    (entry) => DropdownMenuItem(
                                          value: entry.key,
                                          child: Text(entry.value),
                                        ))
                                .toList(),
                            onChanged: _.changeseasonValue),
                      ),
                      SizedBox(
                        width: Get.size.width * 0.32,
                        child: DropdownButtonFormField<int>(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            decoration: getOldTextFieldDecoration(context, ""),
                            value: _.yearValue,
                            items: _.yearValuesMap.entries
                                .map<DropdownMenuItem<int>>(
                                    (entry) => DropdownMenuItem(
                                          value: entry.key,
                                          child: Text(entry.value.toString()),
                                        ))
                                .toList(),
                            onChanged: _.changeyearValue),
                      )
                    ],
                  );
                },
              ),
            ),
            Obx(
              () => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (controller.listings.length),
                  itemBuilder: (context, index) {
                    return CoverForAnime(anime: controller.listings[index]);
                  }),
            ),
            GetBuilder<ExploreController>(
              init: controller,
              initState: (_) {},
              builder: (_) {
                log(_.status.isLoadingMore.toString());
                return (_.status.isLoadingMore || _.status.isLoading)
                    ? const Center(
                        child: ProgressIndicatorButton(
                          radius: 20,
                        ),
                      )
                    : (_.status.isEmpty)
                        ? const Center(child: Text(Values.noResults))
                        : (_.status.isError)
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _.status.errorMessage ?? '',
                                        textAlign: TextAlign.center,
                                      ),
                                      OutlinedButton(
                                        onPressed: controller.searchListings,
                                        child: const Text(Values.retry),
                                        style: Theme.of(context)
                                            .elevatedButtonTheme
                                            .style
                                            ?.copyWith(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      Theme.of(context)
                                                          .cardColor),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              );
              },
            ),
          ],
        ),
      ),
    );
  }
}
