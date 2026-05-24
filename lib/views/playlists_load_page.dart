import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlists_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistsLoadPage extends StatelessWidget {
  const PlaylistsLoadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlaylistsController _pc = Get.find();
    return Container(
        color: Colors.transparent,
        child: GetBuilder<PlaylistsController>(
          init: _pc,
          initState: (_) {},
          builder: (_) {
            if(_pc.wait.value){
              return const Center(
                child: ProgressIndicatorButton(
                  radius: 20,
                ),
              );
            } else {
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
                             _pc.printdata(),
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
            }
          },
        ));
  }
}
