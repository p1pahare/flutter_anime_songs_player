import 'dart:math';

import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/album_detail_page.dart';
import 'package:anime_themes_player/widgets/blurred_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoverForAnime extends StatelessWidget {
  const CoverForAnime({Key? key, this.anime}) : super(key: key);
  final Anime? anime;
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
        height: 160,
        width: context.height * 0.9,
        child: Stack(
          children: [
            BlurredImageBackground(
              imagePath: anime?.getImageUrl() ?? Values.noImage,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: max((context.width * 0.4), 25) - 25,
                right: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime?.name ?? "-",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Values.cdTitle,
                  ),
                  if (anime?.getRelease() != null)
                    Text(
                      anime!.getRelease(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Values.cdSubtitle,
                    ),
                  if (anime?.getStudio() != null)
                    Text(
                      anime!.getStudio(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Values.cdSubtitle,
                    ),
                  if (anime?.animethemes.isNotEmpty == true)
                    Text(
                      "${anime?.animethemes.length} ${(anime!.animethemes.length > 1 ? Values.themes : Values.theme).toLowerCase()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Values.cdSubtitle,
                    ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    Get.toNamed(AlbumDetailPage.routeName, arguments: anime);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
