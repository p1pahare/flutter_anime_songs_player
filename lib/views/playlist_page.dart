import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/playlist_forms_page.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlaylistController _pc = Get.find();
    return Container(
        color: Colors.transparent,
        child: GetBuilder<PlaylistController>(
          init: _pc,
          initState: (_) {},
          builder: (_) {
            switch (_.mode.value) {
              case LoginMode.loggedIn:
                return Container(
                  color: Colors.pink,
                );
              case LoginMode.failed:
                return Container(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Text(
                          Values.noInternetMessage,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              Get.find<DashboardController>().isLogin(),
                          child: const Text(Values.retry),
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).cardColor),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              case LoginMode.loading:
                return const Center(
                  child: ProgressIndicatorButton(
                    radius: 20,
                  ),
                );
              default:
                return PlaylistFormsPage(pc: _pc);
            }
          },
        ));
  }
}
