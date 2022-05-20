import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/theme_holder_for_animethemesmain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistDetail extends StatelessWidget {
  const PlaylistDetail({Key? key, this.playlist}) : super(key: key);
  final Map<int, String>? playlist;
  static const routeName = '/PlaylistPage';
  @override
  Widget build(BuildContext context) {
    List<String> playlist1 = playlist!.values.toList().sublist(2);
    playlist1.removeWhere((element) => element == '0000000');
    Get.find<PlaylistController>().themesFromThemeId(playlist1);
    return GetBuilder<PlaylistController>(
      id: "detail",
      init: PlaylistController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
            appBar: AppBar(
              title: Text(
                _.getReadablePlaylistName(playlist?[1] ?? ''),
              ),
            ),
            body: SizedBox(
                height: Get.height,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 130,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [],
                            )),
                        if (_.status.isLoading || _.status.isLoadingMore)
                          const Center(child: ProgressIndicatorButton())
                        else if (_.status.isError)
                          Center(child: Text(_.status.errorMessage ?? ''))
                        else if (_.status.isSuccess)
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: (_.listings.length),
                              itemBuilder: (context, index) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ThemeHolderForAnimethemesMain(
                                      animethemesMain: _.listings[index],
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () => _.deleteFromPlayList(
                                            playlist![0].toString(),
                                            _.listings[index].id.toString()),
                                        child: const Icon(
                                          Icons.cancel_rounded,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              })
                        else if (_.status.isEmpty)
                          const Center(child: Text(Values.noResults)),
                      ],
                    ),
                  ),
                )));
      },
    );
  }
}
