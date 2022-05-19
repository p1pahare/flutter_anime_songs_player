import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/widgets/cover_for_animemain.dart';
import 'package:anime_themes_player/widgets/song_card_for_animethemes.dart';

import 'package:flutter/material.dart';
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
  List<Map<Animethemes, Animethemeentries>> allVersionThemes = [];
  @override
  void initState() {
    for (Animethemes animethemes in widget.animeMain!.animethemes) {
      for (Animethemeentries animethemesEntries
          in animethemes.animethemeentries) {
        if (allVersionThemes.isEmpty ||
            allVersionThemes.last.entries.length >= 4) {
          allVersionThemes.add({animethemes: animethemesEntries});
        } else {
          allVersionThemes.last
              .addEntries([MapEntry(animethemes, animethemesEntries)]);
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
          color: Theme.of(context).cardColor,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          title: CoverForAnimeMain(
            animeMain: widget.animeMain,
          ),
          content: SizedBox(
            height: 300,
            child: PageView.builder(
                itemCount: allVersionThemes.length,
                itemBuilder: (context, indexPage) {
                  List<MapEntry<Animethemes, Animethemeentries>> entryList =
                      allVersionThemes[indexPage].entries.toList();
                  return Column(
                      children:
                          List<Widget>.generate(entryList.length, (indexList) {
                    return SongCardForAnimethemes(
                        animethemes: entryList[indexList].key,
                        animethemeentries: entryList[indexList].value);
                  }));
                }),
          ),
          openedHeight: 450,
          closedHeight: 150),
    );
  }
}
