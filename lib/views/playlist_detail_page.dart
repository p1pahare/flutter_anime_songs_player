import 'package:anime_themes_player/controllers/playlists_controller.dart';
import 'package:anime_themes_player/models/playlist_track.dart';
import 'package:anime_themes_player/models/playlists_response.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_gradient_image/random_gradient_image.dart';

class PlaylistDetailsPage extends StatefulWidget {
  const PlaylistDetailsPage({super.key, required this.playlistArg});
  static const routeName = '/PlaylistDetailsPage';
  final Playlist playlistArg;

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  PlaylistsController get _controller => Get.find<PlaylistsController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tracks = _controller.tracksFor(widget.playlistArg.id);
      final status = _controller.statusForTracks(widget.playlistArg.id);
      if (tracks.isEmpty && !status.isLoading) {
        _controller.fetchTracks(widget.playlistArg.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (!_controller.hasMoreTracks(widget.playlistArg.id)) return;
    if (_controller.isLoadingMoreTracks(widget.playlistArg.id)) return;

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _controller.fetchMoreTracks(playlistId: widget.playlistArg.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.playlistArg.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeletePlaylistConfirmation(
                          context,
                          _controller,
                          widget.playlistArg,
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.14),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: InkWell(
                  onTap: () async {
                    await _controller.loadPlaylistSongsToCurrentPlaying(
                      playlistId: widget.playlistArg.id,
                      playlistName: widget.playlistArg.name,
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RandomGradientImage(seed: widget.playlistArg.id),
                      Container(
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                      Icon(
                        Icons.shuffle,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 42,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Downloaded',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: false,
                    onChanged: (_) {
                      showMessage(
                          'Download Feature coming soon. Please check back later.');
                    },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GetBuilder<PlaylistsController>(
                init: _controller,
                builder: (_) {
                  final tracks = _.tracksFor(widget.playlistArg.id);
                  final status = _.statusForTracks(widget.playlistArg.id);
                  return status.isLoading || status.isEmpty
                      ? Center(
                          child: status.isLoading
                              ? const ProgressIndicatorButton(radius: 20)
                              : const Text(Values.noResults),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: tracks.length + 1,
                          separatorBuilder: (_, index) {
                            if (index >= tracks.length - 1) {
                              return const SizedBox(height: 12);
                            }
                            return Divider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.18),
                              height: 1,
                            );
                          },
                          itemBuilder: (context, index) {
                            if (index == tracks.length) {
                              if (_
                                  .isLoadingMoreTracks(widget.playlistArg.id)) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: ProgressIndicatorButton(
                                      radius: 18,
                                    ),
                                  ),
                                );
                              }

                              if (_.hasMoreTracks(widget.playlistArg.id)) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () => _.fetchMoreTracks(
                                      playlistId: widget.playlistArg.id,
                                    ),
                                    child: const Text('Load more'),
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            }

                            final track = tracks[index] as PlaylistTrack;
                            final imageListAvailable = track.animethemeentry
                                .animetheme.anime.images.isNotEmpty;
                            final String imageUrl = imageListAvailable
                                ? track.animethemeentry.animetheme.anime.images
                                    .first.link
                                : "";
                            final themeId = track.animethemeentry.animetheme.id;
                            final isFavorite = _.isThemeFavorited(themeId);

                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  color: Theme.of(context).cardColor,
                                  child: imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.music_note,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                ),
                              ),
                              title: Text(
                                track.animethemeentry.animetheme.song.title,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                track.animethemeentry.animetheme.song.artists
                                    .map((artist) => artist.name)
                                    .join(","),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _.toggleThemeFavorite(themeId),
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _showDeleteTrackConfirmation(
                                          context,
                                          _,
                                          widget.playlistArg.id,
                                          track,
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeletePlaylistConfirmation(
  BuildContext context,
  PlaylistsController controller,
  Playlist playlist,
) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete ${playlist.name}?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final deleted = await controller.deletePlaylist(
                playlistId: playlist.id,
              );
              if (deleted) {
                Get.back();
              }
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

void _showDeleteTrackConfirmation(
  BuildContext context,
  PlaylistsController controller,
  String playlistId,
  PlaylistTrack track,
) {
  final title = track.animethemeentry.animetheme.song.title;
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Track'),
        content: Text('Should I delete "$title" from this playlist?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final deleted = await controller.deleteTrackFromPlaylist(
                playlistId: playlistId,
                trackId: track.id,
              );
              showMessage(
                deleted
                    ? 'Track deleted from playlist.'
                    : controller.toastMessage.value,
              );
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
