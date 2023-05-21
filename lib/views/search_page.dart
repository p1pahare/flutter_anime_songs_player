import 'dart:developer';

import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_animemain.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_animethemesmain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchController>();
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
                child: GetBuilder<SearchController>(
                  init: SearchController(),
                  initState: (_) {},
                  builder: (_) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(Values.searchBy),
                            DropdownButton<int>(
                                value: _.searchByValue,
                                items: _.searchValuesMap.entries
                                    .map<DropdownMenuItem<int>>(
                                        (entry) => DropdownMenuItem(
                                              value: entry.key,
                                              child: Text(entry.value),
                                            ))
                                    .toList(),
                                onChanged: _.changesearchByValue)
                          ],
                        ),
                        SizedBox(
                          height: 80,
                          child: TextField(
                            controller: _.search,
                            onSubmitted: (str) => _.onSearch(),
                            onChanged: (s) {
                              _.update();
                            },
                            decoration: InputDecoration(
                                hintText: 'Search Here ...',
                                suffixIcon: SizedBox(
                                  width: 70,
                                  child: Row(
                                    children: [
                                      if (_.search.text.isNotEmpty)
                                        InkWell(
                                            onTap: _.onSearch,
                                            child: const Icon(
                                                Icons.search_rounded)),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      if (_.search.text.isNotEmpty)
                                        InkWell(
                                            onTap: _.onClear,
                                            child: const Icon(
                                                Icons.cancel_rounded)),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Obx(() => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.listings.length,
                  itemBuilder: (context, index) {
                    if (controller.listings[index] is AnimethemesMain) {
                      return ThemeHolderForAnimethemesMain(
                        animethemesMain: controller.listings[index],
                      );
                    }
                    if (controller.listings[index] is AnimeMain) {
                      return ThemeHolderForAnimeMain(
                        animeMain: controller.listings[index],
                      );
                    }

                    return const SizedBox.shrink();
                  })),
              GetBuilder<SearchController>(
                init: SearchController(),
                initState: (_) {},
                builder: (_) {
                  log(_.status.isLoadingMore.toString());
                  return (_.status.isLoadingMore || _.status.isLoading)
                      ? const Center(
                          child: ProgressIndicatorButton(
                          radius: 20,
                        ))
                      : (_.status.isEmpty)
                          ? const Center(child: Text(Values.noResults))
                          : (_.status.isError)
                              ? Center(
                                  child: Text(
                                  _.status.errorMessage ?? '',
                                  textAlign: TextAlign.center,
                                ))
                              : const SizedBox(
                                  height: 0,
                                );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
