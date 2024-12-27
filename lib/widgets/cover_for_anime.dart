import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/blurred_image.dart';
// import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
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
        width: Get.width * 0.9,
        child: Stack(
          children: [
            BlurredImageBackground(
              imagePath: anime?.images.first.link ?? Values.noImage,
            ),
            Padding(
              padding: EdgeInsets.only(left: (Get.width * 0.4) - 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime?.name ?? "-",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffd9d6d3),
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(0.8, 0.6))
                        ]),
                  ),
                  Text(
                    "${anime?.season ?? "??"}/${anime?.year ?? "??"}",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffd9d6d3),
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(0.8, 0.6))
                        ]),
                  ),
                  if (anime?.studios.isNotEmpty == true)
                    Text(
                      "${anime?.studios.first.name}",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffd9d6d3),
                          shadows: [
                            Shadow(
                                color: Colors.black, offset: Offset(0.8, 0.6))
                          ]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));

    // SizedBox(
    //   width: Get.width - 90,
    //   child: Card(
    //       elevation: 0,
    //       color: Theme.of(context).cardColor,
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    //       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //         Container(
    //             clipBehavior: Clip.hardEdge,
    //             decoration:
    //                 BoxDecoration(borderRadius: BorderRadius.circular(7)),
    //             width: Get.width * 0.32,
    //             child: anime?.images.isEmpty == true
    //                 ? Image.asset(
    //                     'lib/assets/no-image.jpg',
    //                     height: 150,
    //                     fit: BoxFit.cover,
    //                   )
    //                 : Image.network(
    //                     anime?.images.first.link ?? Values.errorImage,
    //                     height: 150,
    //                     fit: BoxFit.cover,
    //                     loadingBuilder: (context, child, loadingProcess) =>
    //                         loadingProcess == null
    //                             ? child
    //                             : const ProgressIndicatorButton(),
    //                     errorBuilder: (context, url, error) =>
    //                         const Icon(Icons.error),
    //                     cacheHeight: 160,
    //                     cacheWidth: 160,
    //                   )),
    //         Container(
    //           width: 0.26,
    //           height: 150,
    //           margin: const EdgeInsets.only(right: 20),
    //           color: Colors.brown,
    //         ),
    //         Expanded(
    //           child: SizedBox(
    //             height: 150,
    //             child: Column(
    //               mainAxisSize: MainAxisSize.max,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.spaceAround,
    //               children: [
    //                 Text(
    //                   anime?.name ?? "",
    //                   maxLines: 2,
    //                   overflow: TextOverflow.fade,
    //                   style: const TextStyle(fontSize: 16),
    //                 ),
    //                 Text(
    //                   "${anime?.season} ${anime?.year}",
    //                   overflow: TextOverflow.fade,
    //                   style: const TextStyle(fontSize: 11),
    //                 ),
    //                 Text(
    //                   anime?.studios.isEmpty == true
    //                       ? ''
    //                       : anime?.studios.first.name ?? "",
    //                   overflow: TextOverflow.fade,
    //                   style: const TextStyle(fontSize: 11),
    //                 ),
    //                 const SizedBox(
    //                   height: 50,
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //       ])),
    // );
  }
}
