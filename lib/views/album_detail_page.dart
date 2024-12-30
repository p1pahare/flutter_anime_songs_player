import 'dart:math';
import 'dart:ui';
import 'dart:developer' as dev;
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/theme_album.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/song_card_for_animethemes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumDetailPage extends StatefulWidget {
  const AlbumDetailPage({
    Key? key,
    required this.themeAlbum,
  }) : super(key: key);
  static const routeName = "/AlbumDetailPage";
  final ThemeAlbum themeAlbum;
  @override
  State<AlbumDetailPage> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailPage> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PreferredSize(
        preferredSize: Size.fromHeight(
            Get.find<DashboardController>().playerLoaded ? 100 : 0),
        child: GetBuilder<DashboardController>(builder: (c) {
          return !c.playerLoaded
              ? const SizedBox(
                  height: 0,
                )
              : Container(
                  height: 90,
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  child:
                      PlayerCurrent(c.underPlayer!, stopPlayer: c.stopPlayer));
        }),
      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: AnimeMetaHeader(
              imagePath: widget.themeAlbum.getImageUrl(),
              scrollController: scrollController,
              title: widget.themeAlbum.getTitle(),
              releaseText: widget.themeAlbum.getRelease(),
              studioText: widget.themeAlbum.getStudio(),
            ),
          ),
          SliverList.list(children: [
            ListTile(
              title: Text(widget.themeAlbum.getSynopsis()),
            ),
          ]),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                return SongCardForAnimethemes(
                  animeMain: widget.themeAlbum as Anime,
                  animethemes: widget.themeAlbum.items()[index].key,
                  animethemeentries: widget.themeAlbum.items()[index].value,
                );
              },
              childCount: widget.themeAlbum.items().length,
            ),
          ),
          SliverList.list(
            children: List.generate(
              15,
              (i) => const SizedBox(
                height: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimeMetaHeader extends SliverPersistentHeaderDelegate {
  AnimeMetaHeader({
    required this.imagePath,
    required this.scrollController,
    required this.title,
    required this.releaseText,
    required this.studioText,
  });
  @override
  double get minExtent => Get.height * 0.22; // Minimum size of the header
  @override
  double get maxExtent => Get.height * 0.55; // Maximum size of the header
  final String imagePath;
  final String title;
  final String releaseText;
  final String studioText;
  final ScrollController scrollController;
  bool scrolled = false;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate size of Box A
    final double sizeA = Get.height * 0.44 - shrinkOffset;
    final double scaledSizeA = max(sizeA - 26, 0);
    if (!scrolled && shrinkOffset > 50 && shrinkOffset < 150) {
      scrollController.animateTo(Get.height * 0.33,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.bounceOut);
      scrolled = true;
    }
    if (shrinkOffset < 10) {
      scrolled = false;
    }
    // Calculate Box B's position and size
    final double boxBStartOffset = Get.width * 0.25;
    const double boxBEndOffset = 50.0;
    final double boxBOffset = boxBStartOffset -
        ((shrinkOffset / (maxExtent - minExtent)) *
                (boxBStartOffset - boxBEndOffset))
            .clamp(0.0, boxBStartOffset - boxBEndOffset);
    dev.log("shrinkfofset = $shrinkOffset, sieA = $sizeA ${Get.size}");
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SizedBox(
            height: scaledSizeA,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: imagePath == Values.noImage
                        ? Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          )
                        : Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, url, error) => Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                  ),
                ),
                Container(
                  height: scaledSizeA,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (Get.isDarkMode ? Colors.black : Colors.white)
                            .withOpacity(0.9)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: maxExtent - scaledSizeA,
            width: Get.width,
            color: Get.theme.canvasColor,
            padding: EdgeInsets.only(
                left: 14 +
                    max(
                        shrinkOffset < (Get.width * 0.3)
                            ? shrinkOffset
                            : (Get.width * 0.4),
                        0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    // width: Get.width / 2,
                    child: Text(
                  title,
                  maxLines: shrinkOffset == 0 ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: Get.theme.textTheme.headlineSmall,
                )),
                Text(
                  releaseText,
                ),
                Text(studioText),
              ],
            ),
          ),
        ),
        Positioned(
          top: boxBOffset * 0.8,
          left: boxBOffset * 0.9,
          child: Container(
            height: boxBOffset * 2.5,
            width: boxBOffset * 2.2,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: imagePath == Values.noImage
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.fill,
                    height: 160,
                    width: Get.width * 0.32,
                  )
                : Image.network(
                    imagePath,
                    fit: BoxFit.fill,
                    height: 160,
                    width: Get.width * 0.32,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProcess) =>
                        loadingProcess == null
                            ? child
                            : const ProgressIndicatorButton(),
                    errorBuilder: (context, url, error) => Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.only(
                left: 14,
                top: 45,
              ),
              height: Get.width * 0.12,
              width: Get.width * 0.12,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Colors.black45 : Colors.white38,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_rounded),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
