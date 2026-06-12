import 'package:anime_themes_player/controllers/playlists_controller.dart';
import 'package:anime_themes_player/models/playlist_track.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistDetailsPage extends StatelessWidget {
  const PlaylistDetailsPage({super.key, required this.playlistArg});
  static const routeName = '/PlaylistDetailsPage';
  final Playlist playlistArg;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaylistsController>();

    // Fetch tracks for this playlist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTracks(playlistArg.id);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        playlistArg.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xff1ED760),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shuffle,
                color: Colors.black,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    "Downloaded",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: false,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(
                () => controller.statusTracks.isLoading ||
                        controller.statusTracks.isEmpty
                    ? Center(
                        child: controller.statusTracks.isLoading
                            ? const ProgressIndicatorButton(radius: 20)
                            : const Text(Values.noResults),
                      )
                    : ListView.separated(
                        itemCount: controller.tracksList.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Colors.white10,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final track =
                              controller.tracksList[index] as PlaylistTrack;
                          final imageListAvailable = track.animethemeentry
                              .animetheme.anime.images.isNotEmpty;
                          final String imageUrl = imageListAvailable
                              ? track.animethemeentry.animetheme.anime.images
                                  .first.link
                              : "";

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey.shade900,
                                child: imageUrl.isNotEmpty
                                    ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                                    : const Icon(Icons.music_note),
                              ),
                            ),
                            title: Text(
                              track.animethemeentry.animetheme.song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              track.animethemeentry.animetheme.song.artists.map((artist) => artist.name).join(","),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Color(0xff1ED760),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            GetBuilder<PlaylistsController>(
              init: controller,
              builder: (_) {
                return (_.statusTracks.isLoadingMore)
                    ? const Center(
                        child: ProgressIndicatorButton(
                          radius: 20,
                        ),
                      )
                    : (_.statusTracks.isError)
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _.statusTracks.toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _.fetchTracks(playlistArg.id),
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
    );
  }
}
