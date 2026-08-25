class PlaylistSongsResponse {
  final List<PlaylistSongTrack> tracks;
  final PlaylistSongsLinks links;
  final PlaylistSongsMeta meta;

  PlaylistSongsResponse({
    required this.tracks,
    required this.links,
    required this.meta,
  });

  factory PlaylistSongsResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistSongsResponse(
      tracks: ((json['tracks'] as List?) ?? [])
          .map((e) => PlaylistSongTrack.fromJson(e))
          .toList(),
      links: PlaylistSongsLinks.fromJson(json['links'] ?? {}),
      meta: PlaylistSongsMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracks': tracks.map((e) => e.toJson()).toList(),
      'links': links.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class PlaylistSongDetailResponse {
  final PlaylistSongTrack track;

  PlaylistSongDetailResponse({required this.track});

  factory PlaylistSongDetailResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistSongDetailResponse(
      track: PlaylistSongTrack.fromJson(json['track'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'track': track.toJson(),
    };
  }
}

class PlaylistSongTrack {
  final String id;
  final PlaylistSongVideo video;
  final PlaylistSongAnimeThemeEntry? animethemeentry;
  final PlaylistSongPlaylist? playlist;
  final String album;
  final String title;
  final String artist;
  final String? coverUrl;

  PlaylistSongTrack({
    required this.id,
    required this.video,
    this.animethemeentry,
    this.playlist,
    this.album = '',
    this.title = '',
    this.artist = '',
    this.coverUrl,
  });

  factory PlaylistSongTrack.queue({
    required String id,
    int? videoId,
    String basename = '',
    String filename = '',
    required String audioUrl,
    required String videoUrl,
    String album = '',
    String title = '',
    String artist = '',
    String? coverUrl,
  }) {
    return PlaylistSongTrack(
      id: id,
      video: PlaylistSongVideo(
        id: videoId ?? 0,
        basename: basename,
        filename: filename,
        lyrics: false,
        nc: false,
        overlap: null,
        path: '',
        resolution: 0,
        size: 0,
        source: '',
        subbed: false,
        uncen: false,
        tags: '',
        link: videoUrl,
        audio: PlaylistSongAudio(
          id: 0,
          basename: '',
          filename: '',
          path: '',
          size: 0,
          link: audioUrl,
        ),
      ),
      album: album,
      title: title,
      artist: artist,
      coverUrl: coverUrl,
    );
  }

  PlaylistSongTrack copyWithQueueMeta({
    String? album,
    String? title,
    String? artist,
    String? coverUrl,
  }) {
    return PlaylistSongTrack(
      id: id,
      video: video,
      album: album ?? this.album,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  factory PlaylistSongTrack.fromJson(Map<String, dynamic> json) {
    return PlaylistSongTrack(
      id: json['id'] ?? '',
      video: json['video'] is Map<String, dynamic>
          ? PlaylistSongVideo.fromJson(Map<String, dynamic>.from(json['video']))
          : PlaylistSongVideo.empty(),
      animethemeentry: json['animethemeentry'] is Map<String, dynamic>
          ? PlaylistSongAnimeThemeEntry.fromJson(
              Map<String, dynamic>.from(json['animethemeentry']),
            )
          : null,
      playlist: json['playlist'] is Map<String, dynamic>
          ? PlaylistSongPlaylist.fromJson(
              Map<String, dynamic>.from(json['playlist']),
            )
          : null,
      album: json['album'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      coverUrl: json['coverUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video': video.toJson(),
      'animethemeentry': animethemeentry?.toJson(),
      'playlist': playlist?.toJson(),
      'album': album,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
    };
  }

  String get audioUrl => video.audio.link;

  String get videoUrl => video.link;

  String get resolvedTitle {
    if (title.isNotEmpty) return title;
    final nestedTitle = animethemeentry?.animetheme.song.title;
    if (nestedTitle?.isNotEmpty == true) {
      return nestedTitle!;
    }
    return video.filename;
  }

  String get resolvedArtist {
    if (artist.isNotEmpty) return artist;
    final nestedArtists = animethemeentry?.animetheme.song.artists
        .map((artist) => artist.name)
        .join(',');
    return nestedArtists ?? '';
  }

  String get resolvedAlbum {
    final nestedAlbum = animethemeentry?.animetheme.anime.name;
    if (nestedAlbum?.isNotEmpty == true) return nestedAlbum!;
    if (album.isNotEmpty) return album;
    return '';
  }

  String? get resolvedCoverUrl {
    if (coverUrl?.isNotEmpty == true) return coverUrl;
    final images = animethemeentry?.animetheme.anime.images;
    if (images != null && images.isNotEmpty) {
      return images.first.link;
    }
    return null;
  }

  String get displayTitle => resolvedTitle;

  Uri? get artUri => resolvedCoverUrl?.isNotEmpty == true
      ? Uri.parse(resolvedCoverUrl!)
      : null;
}

class PlaylistSongAnimeThemeEntry {
  final int id;
  final String episodes;
  final String? notes;
  final bool nsfw;
  final bool spoiler;
  final int version;
  final int? tracksCount;
  final PlaylistSongAnimeTheme animetheme;

  PlaylistSongAnimeThemeEntry({
    required this.id,
    required this.episodes,
    required this.notes,
    required this.nsfw,
    required this.spoiler,
    required this.version,
    required this.tracksCount,
    required this.animetheme,
  });

  factory PlaylistSongAnimeThemeEntry.fromJson(Map<String, dynamic> json) {
    return PlaylistSongAnimeThemeEntry(
      id: json['id'] ?? 0,
      episodes: json['episodes'] ?? '',
      notes: json['notes'],
      nsfw: json['nsfw'] ?? false,
      spoiler: json['spoiler'] ?? false,
      version: json['version'] ?? 0,
      tracksCount: json['tracks_count'] is int
          ? json['tracks_count'] as int
          : int.tryParse(json['tracks_count']?.toString() ?? ''),
      animetheme: PlaylistSongAnimeTheme.fromJson(
        Map<String, dynamic>.from(json['animetheme'] ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episodes': episodes,
      'notes': notes,
      'nsfw': nsfw,
      'spoiler': spoiler,
      'version': version,
      'tracks_count': tracksCount,
      'animetheme': animetheme.toJson(),
    };
  }
}

class PlaylistSongAnimeTheme {
  final int id;
  final int? sequence;
  final String slug;
  final String type;
  final PlaylistSongAnime anime;
  final PlaylistSongSong song;

  PlaylistSongAnimeTheme({
    required this.id,
    required this.sequence,
    required this.slug,
    required this.type,
    required this.anime,
    required this.song,
  });

  factory PlaylistSongAnimeTheme.fromJson(Map<String, dynamic> json) {
    return PlaylistSongAnimeTheme(
      id: json['id'] ?? 0,
      sequence: json['sequence'],
      slug: json['slug'] ?? '',
      type: json['type'] ?? '',
      anime: PlaylistSongAnime.fromJson(
          Map<String, dynamic>.from(json['anime'] ?? {})),
      song: PlaylistSongSong.fromJson(
          Map<String, dynamic>.from(json['song'] ?? {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sequence': sequence,
      'slug': slug,
      'type': type,
      'anime': anime.toJson(),
      'song': song.toJson(),
    };
  }
}

class PlaylistSongAnime {
  final int id;
  final String name;
  final String mediaFormat;
  final String season;
  final String slug;
  final String synopsis;
  final int year;
  final List<PlaylistSongAnimeImage> images;

  PlaylistSongAnime({
    required this.id,
    required this.name,
    required this.mediaFormat,
    required this.season,
    required this.slug,
    required this.synopsis,
    required this.year,
    required this.images,
  });

  factory PlaylistSongAnime.fromJson(Map<String, dynamic> json) {
    return PlaylistSongAnime(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mediaFormat: json['media_format'] ?? '',
      season: json['season'] ?? '',
      slug: json['slug'] ?? '',
      synopsis: json['synopsis'] ?? '',
      year: json['year'] ?? 0,
      images: ((json['images'] as List?) ?? [])
          .map((e) =>
              PlaylistSongAnimeImage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'media_format': mediaFormat,
      'season': season,
      'slug': slug,
      'synopsis': synopsis,
      'year': year,
      'images': images.map((e) => e.toJson()).toList(),
    };
  }
}

class PlaylistSongAnimeImage {
  final int id;
  final String facet;
  final String path;
  final String link;

  PlaylistSongAnimeImage({
    required this.id,
    required this.facet,
    required this.path,
    required this.link,
  });

  factory PlaylistSongAnimeImage.fromJson(Map<String, dynamic> json) {
    return PlaylistSongAnimeImage(
      id: json['id'] ?? 0,
      facet: json['facet'] ?? '',
      path: json['path'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facet': facet,
      'path': path,
      'link': link,
    };
  }
}

class PlaylistSongSong {
  final int id;
  final String title;
  final List<PlaylistSongArtist> artists;

  PlaylistSongSong({
    required this.id,
    required this.title,
    required this.artists,
  });

  factory PlaylistSongSong.fromJson(Map<String, dynamic> json) {
    return PlaylistSongSong(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      artists: ((json['artists'] as List?) ?? [])
          .map((e) => PlaylistSongArtist.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artists': artists.map((e) => e.toJson()).toList(),
    };
  }
}

class PlaylistSongArtist {
  final int id;
  final String name;
  final String slug;
  final String? information;

  PlaylistSongArtist({
    required this.id,
    required this.name,
    required this.slug,
    this.information,
  });

  factory PlaylistSongArtist.fromJson(Map<String, dynamic> json) {
    return PlaylistSongArtist(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      information: json['information'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'information': information,
    };
  }
}

class PlaylistSongPlaylist {
  final String id;
  final String name;
  final String? description;
  final String visibility;

  PlaylistSongPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.visibility,
  });

  factory PlaylistSongPlaylist.fromJson(Map<String, dynamic> json) {
    return PlaylistSongPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      visibility: json['visibility'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'visibility': visibility,
    };
  }
}

class PlaylistSongVideo {
  final int id;
  final String basename;
  final String filename;
  final bool lyrics;
  final bool nc;
  final String? overlap;
  final String path;
  final int resolution;
  final int size;
  final String source;
  final bool subbed;
  final bool uncen;
  final String tags;
  final String link;
  final PlaylistSongAudio audio;

  PlaylistSongVideo({
    required this.id,
    required this.basename,
    required this.filename,
    required this.lyrics,
    required this.nc,
    required this.overlap,
    required this.path,
    required this.resolution,
    required this.size,
    required this.source,
    required this.subbed,
    required this.uncen,
    required this.tags,
    required this.link,
    required this.audio,
  });

  factory PlaylistSongVideo.empty() {
    return PlaylistSongVideo(
      id: 0,
      basename: '',
      filename: '',
      lyrics: false,
      nc: false,
      overlap: null,
      path: '',
      resolution: 0,
      size: 0,
      source: '',
      subbed: false,
      uncen: false,
      tags: '',
      link: '',
      audio: PlaylistSongAudio.empty(),
    );
  }

  factory PlaylistSongVideo.fromJson(Map<String, dynamic> json) {
    return PlaylistSongVideo(
      id: json['id'] ?? 0,
      basename: json['basename'] ?? '',
      filename: json['filename'] ?? '',
      lyrics: json['lyrics'] ?? false,
      nc: json['nc'] ?? false,
      overlap: json['overlap'],
      path: json['path'] ?? '',
      resolution: json['resolution'] ?? 0,
      size: json['size'] ?? 0,
      source: json['source'] ?? '',
      subbed: json['subbed'] ?? false,
      uncen: json['uncen'] ?? false,
      tags: json['tags'] ?? '',
      link: json['link'] ?? '',
      audio: PlaylistSongAudio.fromJson(json['audio'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'basename': basename,
      'filename': filename,
      'lyrics': lyrics,
      'nc': nc,
      'overlap': overlap,
      'path': path,
      'resolution': resolution,
      'size': size,
      'source': source,
      'subbed': subbed,
      'uncen': uncen,
      'tags': tags,
      'link': link,
      'audio': audio.toJson(),
    };
  }
}

class PlaylistSongAudio {
  final int id;
  final String basename;
  final String filename;
  final String path;
  final int size;
  final String link;

  PlaylistSongAudio({
    required this.id,
    required this.basename,
    required this.filename,
    required this.path,
    required this.size,
    required this.link,
  });

  factory PlaylistSongAudio.empty() {
    return PlaylistSongAudio(
      id: 0,
      basename: '',
      filename: '',
      path: '',
      size: 0,
      link: '',
    );
  }

  factory PlaylistSongAudio.fromJson(Map<String, dynamic> json) {
    return PlaylistSongAudio(
      id: json['id'] ?? 0,
      basename: json['basename'] ?? '',
      filename: json['filename'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'basename': basename,
      'filename': filename,
      'path': path,
      'size': size,
      'link': link,
    };
  }
}

class PlaylistSongsLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PlaylistSongsLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PlaylistSongsLinks.fromJson(Map<String, dynamic> json) {
    return PlaylistSongsLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }
}

class PlaylistSongsMeta {
  final int currentPage;
  final String currentPageUrl;
  final int from;
  final String path;
  final int perPage;
  final int to;

  PlaylistSongsMeta({
    required this.currentPage,
    required this.currentPageUrl,
    required this.from,
    required this.path,
    required this.perPage,
    required this.to,
  });

  factory PlaylistSongsMeta.fromJson(Map<String, dynamic> json) {
    return PlaylistSongsMeta(
      currentPage: json['current_page'] ?? 0,
      currentPageUrl: json['current_page_url'] ?? '',
      from: json['from'] ?? 0,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 0,
      to: json['to'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'current_page_url': currentPageUrl,
      'from': from,
      'path': path,
      'per_page': perPage,
      'to': to,
    };
  }
}
