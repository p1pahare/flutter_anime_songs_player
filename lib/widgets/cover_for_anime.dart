
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
  child: ConstrainedBox(
    // Prevents the card from becoming infinitely wide on tablets/web
    constraints: const BoxConstraints(maxWidth: 500), 
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias, // Important for the rounded corners
      child: InkWell(
        onTap: () => Get.toNamed(AlbumDetailPage.routeName, arguments: anime),
        child: SizedBox(
          height: 160,
          child: Stack(
            children: [
              // Background Layer
              BlurredImageBackground(
                imagePath: anime?.getImageUrl() ?? Values.noImage,
              ),
              
              // Content Layer
              Row(
                children: [
                  const SizedBox(width: 120), // Same as posterWidth
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          const SizedBox(height: 4),
                          if (anime?.getRelease() != null)
                            Text(
                              anime!.getRelease(),
                              maxLines: 1,
                              style: Values.cdSubtitle,
                            ),
                          if (anime?.getStudio() != null)
                            Text(
                              anime!.getStudio(),
                              maxLines: 1,
                              style: Values.cdSubtitle,
                            ),
                          if (anime?.animethemes.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "${anime?.animethemes.length} themes",
                                style: Values.cdSubtitle.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
