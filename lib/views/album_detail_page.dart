import 'dart:ui';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/theme_album.dart';
import 'package:anime_themes_player/utilities/values.dart';
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
  final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
  
  // 1. Image Size: Slightly smaller when collapsed
  final double imageWidth = lerpDouble(120, 80, progress)!;
  final double imageHeight = lerpDouble(170, 110, progress)!;
  
  // 2. Left Position: Moving from 20 (expanded) to 50 (collapsed) as requested
  final double leftPosition = lerpDouble(20, 50, progress)!;

  // 3. Top Position: 
  // We calculate safe areas to ensure it stays vertically centered in the minExtent
  final double expandedTop = maxExtent - imageHeight - 40; 
  final double collapsedTop = (minExtent / 2) - (imageHeight / 2) + (MediaQuery.of(context).padding.top / 2);
  final double topPosition = lerpDouble(expandedTop, collapsedTop, progress)!;

  return Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Background Blurred Image (fades out as we collapse)
        Opacity(
          opacity: 1,
          child: _buildBlurredBackground(context),
        ),

        // Text Content (Titles)
        Positioned(
          // Text starts after the image + a small gap
          left: leftPosition + imageWidth + 15,
          right: 20,
          // Instead of bottom: 20, we use top: topPosition to keep it aligned with the image
          top: topPosition, 
          height: imageHeight, // Force the column to be the same height as the image
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, // Center text vertically relative to the image
            children: [
              Text(
                title,
                style: Values.cdTitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: lerpDouble(20, 15, progress),
                ),
                maxLines: progress > 0.5 ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              // We use a SizeTransition-like logic: hide details as we reach collapsed state
              ...[
                const SizedBox(height: 4),
                Text(
                  releaseText, 
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                ),
                Text(
                  studioText, 
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),

        // Floating Image Card (The Poster)
        Positioned(
          left: leftPosition,
          top: topPosition,
          child: Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8, 
                  color: Colors.black.withOpacity(lerpDouble(0.26, 0.0, progress)!)
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(BoxFit.cover),
          ),
        ),

        // Back Button (Adjusted for status bar)
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 10,
          child: SizedBox(
            height: kToolbarHeight,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildBlurredBackground(BuildContext context) {
  return Stack(
    children: [
      // 1. The Actual Image (Blurred)
      Positioned.fill(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2), // Darkens the image slightly
              BlendMode.darken,
            ),
            child: _buildImage(BoxFit.cover),
          ),
        ),
      ),

      // 2. The Gradient Overlay (Transition to Scaffold Background)
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Top: Transparent or slightly tinted for the status bar
                Colors.black.withOpacity(0.3),
                // Middle: Transition
                Colors.transparent,
                // Bottom: Smooth fade into the rest of the page
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.4, 0.8, 1.0],
            ),
          ),
        ),
      ),
    ],
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