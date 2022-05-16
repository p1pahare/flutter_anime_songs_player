import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends GetView<SearchController> {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.bringCats();
    return SizedBox(
      height: Get.height,
      child: SingleChildScrollView(
        child: Column(
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
                          onSubmitted: (str) {},
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
                                          child:
                                              const Icon(Icons.search_rounded)),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (_.search.text.isNotEmpty)
                                      InkWell(
                                          onTap: _.onClear,
                                          child:
                                              const Icon(Icons.cancel_rounded)),
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
            controller.obx(
              (state) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state?.length,
                  itemBuilder: ((context, index) =>
                      ThemeHolder(cat: state?[index]))),

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
    );
  }
}
