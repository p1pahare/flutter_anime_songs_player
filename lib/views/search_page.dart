import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_animemain.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_animethemesmain.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_cat.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_themesmalani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends GetView<SearchController> {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.initalizeLoadingStatus();
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
              // if (controller.listings.isNotEmpty)
              controller.obx(
                (state) => ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (state!.length),
                    itemBuilder: (context, index) {
                      if (index == state.length) {
                        return const ProgressIndicatorButton();
                      }
                      if (state[0] is AnimethemesMain) {
                        return ThemeHolderForAnimethemesMain(
                          animethemesMain: state[index],
                        );
                      }
                      if (state[0] is AnimeMain) {
                        return ThemeHolderForAnimeMain(
                          animeMain: state[index],
                        );
                      }
                      if (state[0] is ThemesMalAni) {
                        return ThemeHolderForThemesMalani(
                          themesMalAni: state[index],
                        );
                      }
                      return ThemeHolderForCat(cat: state[index]);
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
