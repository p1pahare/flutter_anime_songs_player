import 'dart:ui';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/theme_album.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:anime_themes_player/widgets/see_more_less_widget.dart';
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
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          CustomScrollView(
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
                SeeMoreLessWidget(
                  textData: widget.themeAlbum.getSynopsis(),
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
                  widget.themeAlbum.items().length < 12
                      ? 12 - widget.themeAlbum.items().length
                      : 0,
                  (i) => const SizedBox(
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GetBuilder<DashboardController>(builder: (c) {
              return !c.playerLoaded
                  ? const SizedBox(
                      height: 0,
                    )
                  : SizedBox(
                      height: 100,
                      child: PlayerCurrent(c.underPlayer!,
                          stopPlayer: c.stopPlayer));
            }),
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

  final String imagePath;
  final String title;
  final String releaseText;
  final String studioText;
  final ScrollController scrollController;

  // Use fixed values or media query logic for extents
  @override
  double get minExtent => kToolbarHeight + 60; // Standard collapsed height
  @override
  double get maxExtent => 320.0; // Fixed max height for consistency

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0.0 = fully expanded, 1.0 = fully collapsed
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    
    // Dynamic sizes based on progress
    final double imageWidth = (120 - (progress * 40)).clamp(60.0, 120.0);
    final double imageHeight = (170 - (progress * 50)).clamp(80.0, 170.0);
    
    // Horizontal position: starts at 20, moves slightly right when collapsed
    final double leftPosition = lerpDouble(20, 10, progress)!;
    // Vertical position: anchored toward bottom, but adjusts with shrink
    final double topPosition = lerpDouble(maxExtent - imageHeight - 20, minExtent / 2 - imageHeight / 2, progress)!;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Blurred Image
          Opacity(
            opacity: (1 - progress).clamp(0.0, 1.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: _buildImage(BoxFit.cover),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Text Content (Titles)
          Positioned(
            left: leftPosition + imageWidth + 15,
            right: 20,
            bottom: 20,
            top: progress > 0.5 ? null : null, // Adjust based on need
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: lerpDouble(20, 16, progress),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (progress < 0.6) ...[
                  Text(releaseText, style: Theme.of(context).textTheme.bodyMedium),
                  Text(studioText, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),

          // 3. Floating Image Card (The Poster)
          Positioned(
            left: leftPosition,
            top: topPosition.clamp(10.0, maxExtent), // Prevents going off-top
            child: Container(
              width: imageWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImage(BoxFit.cover),
            ),
          ),

          // 4. Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BoxFit fit) {
    if (imagePath == "no_image") {
      return Image.asset(imagePath, fit: fit);
    }
    return Image.network(
      imagePath,
      fit: fit,
      errorBuilder: (context, _, __) => Container(color: Colors.grey),
    );
  }

  @override
  bool shouldRebuild(covariant AnimeMetaHeader oldDelegate) => true;
}