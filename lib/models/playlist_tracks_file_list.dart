// playlist_tracks_response.dart

class PlaylistTracksFileList {
  final List<Track> tracks;
  final Links links;
  final Meta meta;

  PlaylistTracksFileList({
    required this.tracks,
    required this.links,
    required this.meta,
  });

  factory PlaylistTracksFileList.fromJson(Map<String, dynamic> json) {
    return PlaylistTracksFileList(
      tracks: ((json['tracks'] as List?) ?? [])
          .map((e) => Track.fromJson(e))
          .toList(),
      links: Links.fromJson(json['links'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
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

class Track {
  final String id;
  final Video video;

  Track({
    required this.id,
    required this.video,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '',
      video: Video.fromJson(json['video'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video': video.toJson(),
    };
  }
}

class Video {
  final int id;
  final String basename;
  final String filename;
  final bool lyrics;
  final bool nc;
  final dynamic overlap;
  final String path;
  final int resolution;
  final int size;
  final String source;
  final bool subbed;
  final bool uncen;
  final String tags;
  final String link;
  final Audio audio;

  Video({
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

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
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
      audio: Audio.fromJson(json['audio'] ?? {}),
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

class Audio {
  final int id;
  final String basename;
  final String filename;
  final String path;
  final int size;
  final String link;

  Audio({
    required this.id,
    required this.basename,
    required this.filename,
    required this.path,
    required this.size,
    required this.link,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['id'],
      basename: json['basename'],
      filename: json['filename'],
      path: json['path'],
      size: json['size'],
      link: json['link'],
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

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
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

class Meta {
  final int currentPage;
  final String currentPageUrl;
  final int from;
  final String path;
  final int perPage;
  final int to;

  Meta({
    required this.currentPage,
    required this.currentPageUrl,
    required this.from,
    required this.path,
    required this.perPage,
    required this.to,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      currentPageUrl: json['current_page_url'],
      from: json['from'],
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
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