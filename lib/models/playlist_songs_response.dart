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

class PlaylistSongTrack {
  final String id;
  final PlaylistSongVideo video;
  final String album;
  final String title;
  final String artist;
  final String? coverUrl;

  PlaylistSongTrack({
    required this.id,
    required this.video,
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
      video: PlaylistSongVideo.fromJson(json['video'] ?? {}),
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
      'album': album,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
    };
  }

  String get audioUrl => video.audio.link;

  String get videoUrl => video.link;

  String get displayTitle => title.isNotEmpty ? title : video.filename;

  Uri? get artUri => coverUrl?.isNotEmpty == true ? Uri.parse(coverUrl!) : null;
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
