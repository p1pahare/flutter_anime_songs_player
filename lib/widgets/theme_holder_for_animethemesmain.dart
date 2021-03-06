import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/widgets/song_card_for_animethemesmain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeHolderForAnimethemesMain extends StatelessWidget {
  const ThemeHolderForAnimethemesMain(
      {Key? key, this.animethemesMain, this.showOnlyOne = false})
      : super(key: key);
  final AnimethemesMain? animethemesMain;
  final bool? showOnlyOne;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: Get.width - 50,
        child: Column(
            children: List<Widget>.generate(
                showOnlyOne! && animethemesMain!.animethemeentries.isNotEmpty
                    ? 1
                    : animethemesMain!.animethemeentries.length,
                (index) => SongCardForAnimethemesMain(
                      animethemesMain: animethemesMain,
                      animethemeentries:
                          animethemesMain!.animethemeentries[index],
                    ))));
  }
}
