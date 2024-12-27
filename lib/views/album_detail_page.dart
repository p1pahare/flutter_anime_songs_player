import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/animethemes.dart';
import 'package:anime_themes_player/models/theme_album.dart';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumDetailPage extends StatefulWidget {
  const AlbumDetailPage({
    Key? key,
  }) : super(key: key);
  static const routeName = "/AlbumDetailPage";
  @override
  State<AlbumDetailPage> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailPage> {
  List<Map<AmAnimethemeentries, AmAnimethemes>> allVersionThemes1 = [];
  List<Map<AtmAnimethemeentries, Animethemes>> allVersionThemes2 = [];
  List<Map<Themes, ThemesMalAni>> allVersionThemes3 = [];
  late final ThemeAlbum? themeAlbum;
  @override
  void initState() {
    themeAlbum = Get.find<DashboardController>().themeAlbum;
    if (themeAlbum != null) {
      if (themeAlbum is Anime) {
        Anime animeMain = themeAlbum as Anime;
        for (AmAnimethemes animethemes in animeMain.animethemes) {
          for (AmAnimethemeentries animethemesEntries
              in animethemes.animethemeentries) {
            if (allVersionThemes1.isEmpty ||
                allVersionThemes1.last.entries.length >= 4) {
              allVersionThemes1.add({animethemesEntries: animethemes});
            } else {
              allVersionThemes1.last
                  .addEntries([MapEntry(animethemesEntries, animethemes)]);
            }
          }
        }
      } else if (themeAlbum is Animethemes) {
        Animethemes animethemesMain = themeAlbum as Animethemes;
        for (AtmAnimethemeentries animethemesEntries
            in animethemesMain.animethemeentries) {
          if (allVersionThemes2.isEmpty ||
              allVersionThemes2.last.entries.length >= 4) {
            allVersionThemes2.add({animethemesEntries: animethemesMain});
          } else {
            allVersionThemes2.last
                .addEntries([MapEntry(animethemesEntries, animethemesMain)]);
          }
        }
      } else if (themeAlbum is ThemesMalAni) {
        ThemesMalAni themesMalAni = themeAlbum as ThemesMalAni;
        for (Themes themes in themesMalAni.themes) {
          if (allVersionThemes3.isEmpty ||
              allVersionThemes3.last.entries.length >= 4) {
            allVersionThemes3.add({themes: themesMalAni});
          } else {
            allVersionThemes3.last.addEntries([MapEntry(themes, themesMalAni)]);
          }
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Theme.of(context).cardColor,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        height: 200,
        width: Get.width * 0.9,
        child: Column(
          children: [
            Image(
              image: const NetworkImage(
                "https://static.wikia.nocookie.net/bleachfanfiction/images/a/a8/Saki_Picture_Profile.png/revision/latest?cb=20160706072519",
              ),
              height: 160,
              width: Get.width * 0.9,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Text("data")
          ],
        ),
      ),
    ));
  }
}
