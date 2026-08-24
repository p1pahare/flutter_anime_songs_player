import 'package:anime_themes_player/controllers/playlists_controller.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/playlist_detail_page.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_gradient_image/random_gradient_image.dart';

class PlaylistListingScreen extends StatelessWidget {
  const PlaylistListingScreen({super.key});
  static const routeName = '/PlaylistListingScreen';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaylistsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPlaylists();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  _chip(context, "Playlists"),
                  const SizedBox(width: 8),
                  _chip(context, "Podcasts"),
                  const SizedBox(width: 8),
                  _chip(context, "Artists"),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: controller.playlistList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = controller.playlistList[index] as Playlist;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 66,
                            height: 66,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                RandomGradientImage(
                                  seed: item.id.toString(),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.18),
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.playlist_play,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          item.description ?? "",
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          Get.toNamed(PlaylistDetailsPage.routeName,
                              arguments: item);
                        },
                      );
                    },
                  ),
                ),
              ),
              GetBuilder<PlaylistsController>(
                init: controller,
                builder: (_) {
                  return (_.statusPlaylist.isLoadingMore ||
                          _.statusPlaylist.isLoading)
                      ? const Center(
                          child: ProgressIndicatorButton(
                            radius: 20,
                          ),
                        )
                      : (_.statusPlaylist.isEmpty)
                          ? const Center(child: Text(Values.noResults))
                          : (_.statusPlaylist.isError)
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _.statusPlaylist.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () => _.fetchPlaylists(
                                              forceRefresh: true),
                                          child: const Text(Values.retry),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _chip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
