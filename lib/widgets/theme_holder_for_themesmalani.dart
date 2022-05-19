import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:anime_themes_player/widgets/cover_for_themesmalani.dart';
import 'package:flutter/material.dart';
import 'package:tap_to_expand/tap_to_expand.dart';

class ThemeHolderForThemesMalani extends StatelessWidget {
  const ThemeHolderForThemesMalani({Key? key, this.themesMalAni})
      : super(key: key);
  final ThemesMalAni? themesMalAni;
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
          title: CoverForThemesMalani(
            themesMalAni: themesMalAni,
          ),
          content: ListView.builder(
              shrinkWrap: true,
              itemCount: themesMalAni!.themes.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Text(themesMalAni!.themes[index].toJson().toString());
              }),
          openedHeight: 400,
          closedHeight: 100),
    );
  }
}
