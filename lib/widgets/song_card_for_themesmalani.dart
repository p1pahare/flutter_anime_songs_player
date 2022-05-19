import 'dart:developer';
import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:flutter/material.dart';

class SongCardForThemesMalAni extends StatelessWidget {
  const SongCardForThemesMalAni({Key? key, this.themesMalAni, this.themes})
      : super(key: key);
  final ThemesMalAni? themesMalAni;
  final Themes? themes;
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => log("message"),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).bottomAppBarColor)),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "[${themes!.themeType}] ",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        Expanded(
                          child: Text(
                            themes!.themeName,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    // if (animethemes!.song.artists.isNotEmpty)
                    //   Text(
                    //     "${animethemes!.song.artists.map((e) => e.name).toList()}"
                    //         .replaceAll(RegExp('[^A-Za-z0-9, ]'), ''),
                    //     textAlign: TextAlign.start,
                    //     style: const TextStyle(fontSize: 12),
                    //   ),
                  ],
                ),
              ),
              InkWell(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                    child: Icon(
                      Icons.playlist_add,
                    ),
                  )),
              InkWell(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                    child: Icon(Icons.play_circle_fill),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
