import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/widgets/cover_for_themesmalani.dart';
import 'package:anime_themes_player/widgets/song_card_for_themesmalani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tap_to_expand/tap_to_expand.dart';

class ThemeHolderForThemesMalani extends StatefulWidget {
  const ThemeHolderForThemesMalani({Key? key, this.themesMalAni})
      : super(key: key);
  final ThemesMalAni? themesMalAni;

  @override
  State<ThemeHolderForThemesMalani> createState() =>
      _ThemeHolderForThemesMalaniState();
}

class _ThemeHolderForThemesMalaniState
    extends State<ThemeHolderForThemesMalani> {
  List<Map<Themes, ThemesMalAni>> allVersionThemes = [];

  @override
  void initState() {
    for (Themes themes in widget.themesMalAni!.themes) {
      if (allVersionThemes.isEmpty ||
          allVersionThemes.last.entries.length >= 4) {
        allVersionThemes.add({themes: widget.themesMalAni!});
      } else {
        allVersionThemes.last
            .addEntries([MapEntry(themes, widget.themesMalAni!)]);
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
          title: CoverForThemesMalani(
            themesMalAni: widget.themesMalAni,
          ),
          content: SizedBox(
            height: 300,
            child: PageView.builder(
                itemCount: allVersionThemes.length,
                itemBuilder: (context, indexPage) {
                  List<MapEntry<Themes, ThemesMalAni>> entryList =
                      allVersionThemes[indexPage].entries.toList();
                  return Column(
                      children:
                          List<Widget>.generate(entryList.length, (indexList) {
                    return SongCardForThemesMalAni(
                        themesMalAni: entryList[indexList].value,
                        themes: entryList[indexList].key);
                  }));
                }),
          ),
          openedHeight: 350,
          closedHeight: 90),
    );
  }
}
