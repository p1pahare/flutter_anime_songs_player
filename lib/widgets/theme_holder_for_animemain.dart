import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/widgets/cover_for_animemain.dart';
import 'package:anime_themes_player/widgets/song_card_for_animethemes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';
import 'package:tap_to_expand/tap_to_expand.dart';

class ThemeHolderForAnimeMain extends StatefulWidget {
  const ThemeHolderForAnimeMain({Key? key, this.animeMain}) : super(key: key);
  final AnimeMain? animeMain;

  @override
  State<ThemeHolderForAnimeMain> createState() =>
      _ThemeHolderForAnimeMainState();
}

class _ThemeHolderForAnimeMainState extends State<ThemeHolderForAnimeMain> {
  List<Map<Animethemeentries, Animethemes>> allVersionThemes = [];
  @override
  void initState() {
    for (Animethemes animethemes in widget.animeMain!.animethemes) {
      for (Animethemeentries animethemesEntries
          in animethemes.animethemeentries) {
        if (allVersionThemes.isEmpty ||
            allVersionThemes.last.entries.length >= 4) {
          allVersionThemes.add({animethemesEntries: animethemes});
        } else {
          allVersionThemes.last
              .addEntries([MapEntry(animethemesEntries, animethemes)]);
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TapToExpand(
          scrollable: true,
          trailing: Container(
            width: 0,
          ),
          color: Get.theme.cardColor,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          title: CoverForAnimeMain(
            animeMain: widget.animeMain,
          ),
          content: SizedBox(
            height: 300,
            child: PageView.builder(
                itemCount: allVersionThemes.length,
                itemBuilder: (context, indexPage) {
                  List<MapEntry<Animethemeentries, Animethemes>> entryList =
                      allVersionThemes[indexPage].entries.toList();
                  return Column(
                      children:
                          List<Widget>.generate(entryList.length, (indexList) {
                    return SongCardForAnimethemes(
                        animethemes: entryList[indexList].value,
                        animethemeentries: entryList[indexList].key);
                  }));
                }),
          ),
          openedHeight: 450,
          closedHeight: 150),
    );
  }
}
