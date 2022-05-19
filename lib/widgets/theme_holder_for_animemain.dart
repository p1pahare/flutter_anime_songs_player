import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/widgets/cover_for_animemain.dart';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:tap_to_expand/tap_to_expand.dart';

class ThemeHolderForAnimeMain extends StatelessWidget {
  const ThemeHolderForAnimeMain({Key? key, this.animeMain}) : super(key: key);
  final AnimeMain? animeMain;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TapToExpand(
          scrollable: true,
          trailing: Container(
            width: 0,
          ),
          color: Theme.of(context).cardColor,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          title: CoverForAnimeMain(
            animeMain: animeMain,
          ),
          content: ListView.builder(
              shrinkWrap: true,
              itemCount: animeMain!.animethemes.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Text(animeMain!.animethemes[index].toJson().toString());
              }),
          openedHeight: 450,
          closedHeight: 150),
    );
  }
}
