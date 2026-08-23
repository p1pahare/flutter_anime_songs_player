import 'dart:developer';

import 'package:anime_themes_player/controllers/playlists_controller.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/playlist_detail_page.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistListingScreen extends StatelessWidget {
  const PlaylistListingScreen({super.key});
  static const routeName = '/PlaylistListingScreen';

  static const imageUrl =
      "https://images.unsplash.com/photo-1511379938547-c1f69419868d";

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaylistsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPlaylists();
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  _chip("Playlists"),
                  const SizedBox(width: 8),
                  _chip("Podcasts"),
                  const SizedBox(width: 8),
                  _chip("Artists"),
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
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return Container(
                                width: 58,
                                height: 58,
                                color: Colors.grey.shade900,
                                child: const Icon(Icons.music_note),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          item.description ?? "",
                          style: const TextStyle(
                            color: Colors.grey,
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
                  log(_.statusPlaylist.isLoadingMore.toString());
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

  static Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
