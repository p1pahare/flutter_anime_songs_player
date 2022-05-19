import 'dart:developer';

import 'package:anime_themes_player/models/anime_main.dart';
import 'package:flutter/material.dart';

class SongCardForAnimethemes extends StatelessWidget {
  const SongCardForAnimethemes(
      {Key? key, this.animethemes, this.animethemeentries, this.animeMain})
      : super(key: key);
  final AnimeMain? animeMain;
  final Animethemes? animethemes;
  final Animethemeentries? animethemeentries;
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => log("message"),
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
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
                          "[${animethemes!.slug}${animethemeentries!.version == 0 ? '' : ' V${animethemeentries!.version}'}] ",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        Expanded(
                          child: Text(
                            animethemes!.song.title,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    if (animethemes!.song.artists.isNotEmpty)
                      Text(
                        "${animethemes!.song.artists.map((e) => e.name).toList()}"
                            .replaceAll(RegExp('[^A-Za-z0-9, ]'), ''),
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 12),
                      ),
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
