import 'dart:ui';

import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/share_playlist.dart';
import 'package:anime_themes_player/widgets/better_icon_button.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';

class PlaylistDetail extends StatelessWidget {
  const PlaylistDetail({Key? key, this.playlist, required this.playlistIndex})
      : super(key: key);
  final Map<int, String>? playlist;
  final int playlistIndex;
  static const routeName = '/PlaylistPage';
  @override
  Widget build(BuildContext context) {
    List<String> playlist1 = playlist!.values.toList().sublist(2);
    playlist1.removeWhere((element) => element == '0000000');
    Get.find<PlaylistController>().metadataFromThemeId(playlist1);
    return GetBuilder<PlaylistController>(
      id: "detail",
      init: PlaylistController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: AppBar(
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  _.getReadablePlaylistName(playlist?[1] ?? ''),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: Get.theme.iconTheme.color,
                    ),
                    onPressed: () => Get.toNamed(SharePlaylist.routeName,
                        arguments: playlist),
                  )
                ],
              )),
          body: Column(
            children: [
              GetBuilder<DashboardController>(
                  init: DashboardController(),
                  initState: (_) {},
                  builder: (c) {
                    return !c.playerLoaded
                        ? const SizedBox(height: 0)
                        : Container(
                            height: 70,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            child: PlayerCurrent(
                              c.underPlayer!,
                              stopPlayer: c.stopPlayer,
                            ));
                  }),
              SizedBox(
                  height: 50,
                  child: _.listings.length != playlist1.length
                      ? Text(
                          "Downloading Metadata ${_.listings.length + 1} of ${playlist1.length}")
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("${_.listings.length} Themes"),
                              ElevatedButton.icon(
                                  onPressed: () => _.playCurrentListing(),
                                  icon: Icon(
                                    Icons.play_circle,
                                    color:
                                        Get.theme.textTheme.bodyMedium?.color,
                                  ),
                                  label: const Text(Values.playAll))
                            ],
                          ),
                        )),
              Expanded(
                child: (_.status.isLoading || _.status.isLoadingMore)
                    ? const Center(child: ProgressIndicatorButton())
                    : (_.status.isError)
                        ? Center(
                            child: Text(
                            _.status.errorMessage ?? '',
                            textAlign: TextAlign.center,
                          ))
                        : (_.status.isSuccess)
                            ? ImplicitlyAnimatedReorderableList<AudioEntry>(
                                items: _.listings,
                                areItemsTheSame: (oldItem, newItem) =>
                                    oldItem.id == newItem.id,
                                onReorderFinished: (item, from, to, newItems) {
                                  // Remember to update the underlying data when the list has been
                                  // reordered.
                                  _.listings.removeAt(from);
                                  _.listings.insert(to, item);
                                  _.editPlaylistsAndSave(
                                      0,
                                      playlist?.values.first ?? '',
                                      playlist?.values.toList()[1] ?? '');
                                },
                                itemBuilder:
                                    (context, itemAnimation, item, index) {
                                  // Each item must be wrapped in a Reorderable widget.
                                  return Reorderable(
                                    // Each item must have an unique key.
                                    key: ValueKey(item),
                                    // The animation of the Reorderable builder can be used to
                                    // change to appearance of the item between dragged and normal
                                    // state. For example to add elevation when the item is being dragged.
                                    // This is not to be confused with the animation of the itemBuilder.
                                    // Implicit animations (like AnimatedContainer) are sadly not yet supported.
                                    builder: (context, dragAnimation, inDrag) {
                                      final t = dragAnimation.value;
                                      final elevation = lerpDouble(0, 8, t);
                                      final color = Color.lerp(Colors.white,
                                          Colors.white.withOpacity(0.8), t);

                                      return SizeFadeTransition(
                                        sizeFraction: 0.7,
                                        curve: Curves.easeInOut,
                                        animation: itemAnimation,
                                        child: Material(
                                          key: Key(item.id),
                                          color: color,
                                          elevation: elevation ?? 1.0,
                                          type: MaterialType.transparency,
                                          child: _mediaInfoFromAudioEntry(
                                              context, item),
                                        ),
                                      );
                                    },
                                  );
                                },
                                shrinkWrap: true,
                              )
                            : (_.status.isEmpty)
                                ? const Center(child: Text(Values.noResults))
                                : const SizedBox(height: 0),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _mediaInfoFromAudioEntry(BuildContext context, AudioEntry audioEntry) {
    return Material(
      key: ValueKey(audioEntry.id),
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListTile(
              onTap: () {},
              contentPadding: EdgeInsets.zero,
              leading: Handle(
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          audioEntry.art.toString(),
                        ),
                        fit: BoxFit.cover,
                      )),
                ),
              ),
              title: Text(audioEntry.title),
              subtitle: Text(audioEntry.album.toString()),
              trailing: BetterButton(
                icon: Icons.play_circle_rounded,
                onPressed: () async {
                  await Get.find<DashboardController>().init([audioEntry]);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: BetterButton(
              onPressed: () {
                Get.find<PlaylistController>().deleteFromPlayList(
                    playlist?.values.first ?? "", audioEntry.id, context);
              },
              icon: Icons.cancel_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
