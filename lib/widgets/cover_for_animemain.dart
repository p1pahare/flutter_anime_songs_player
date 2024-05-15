import 'package:anime_themes_player/models/anime_main.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoverForAnimeMain extends StatelessWidget {
  const CoverForAnimeMain({Key? key, this.animeMain}) : super(key: key);
  final AnimeMain? animeMain;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width - 90,
      child: Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(7)),
                width: Get.width * 0.32,
                child: animeMain!.images.isEmpty
                    ? Image.asset(
                        'lib/assets/no-image.jpg',
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        animeMain?.images.first.link ?? Values.errorImage,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProcess) =>
                            loadingProcess == null
                                ? child
                                : const ProgressIndicatorButton(),
                        errorBuilder: (context, url, error) =>
                            const Icon(Icons.error),
                        cacheHeight: 160,
                        cacheWidth: 160,
                      )),
            Container(
              width: 0.26,
              height: 150,
              margin: const EdgeInsets.only(right: 20),
              color: Colors.brown,
            ),
            Expanded(
              child: SizedBox(
                height: 150,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      animeMain!.name,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "${animeMain!.season} ${animeMain!.year}",
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      animeMain!.studios.isEmpty
                          ? ''
                          : animeMain!.studios.first.name,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ),
          ])),
    );
  }
}
