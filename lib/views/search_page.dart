import 'dart:developer';

import 'package:anime_themes_player/controllers/search_controller.dart' as sc;
import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/animethemes.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/text_field_decoration.dart';
import 'package:anime_themes_player/views/album_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<sc.SearchController>();
    return SizedBox(
      height: Get.height,
      child: Center(
        child: SingleChildScrollView(
          controller: controller.scroll,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // height: 130,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GetBuilder<sc.SearchController>(
                  init: sc.SearchController(),
                  initState: (_) {},
                  builder: (_) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(Values.searchBy),
                            SizedBox(
                              width: Get.size.width * 0.54,
                              child: DropdownButtonFormField<int>(
                                  value: _.searchByValue,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  decoration:
                                      getOldTextFieldDecoration(context, ""),
                                  items: _.searchValuesMap.entries
                                      .map<DropdownMenuItem<int>>(
                                          (entry) => DropdownMenuItem(
                                                value: entry.key,
                                                child: Text(entry.value),
                                              ))
                                      .toList(),
                                  onChanged: _.changesearchByValue),
                            )
                          ],
                        ),
                        Container(
                          height: 80,
                          margin: const EdgeInsets.only(top: 20),
                          child: TextField(
                            controller: _.search,
                            onSubmitted: (str) => _.onSearch,
                            onChanged: (s) {
                              _.update();
                            },
                            decoration: getOldTextFieldDecoration(
                              context,
                              Values.searchHere,
                              suffix: SizedBox(
                                width: 80,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (_.search.text.isNotEmpty)
                                      InkWell(
                                          onTap: _.onClear,
                                          child: const Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: Icon(Icons.cancel_rounded),
                                          )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    if (_.search.text.isNotEmpty)
                                      InkWell(
                                        onTap: _.onSearch,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Icon(Icons.search_rounded),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
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
                    if (controller.listings[index] is Animethemes) {
                      return const AlbumDetailPage();
                    }
                    if (controller.listings[index] is Anime) {
                      return const AlbumDetailPage();
                    }

                    return const SizedBox.shrink();
                  })),
              GetBuilder<sc.SearchController>(
                init: sc.SearchController(),
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
