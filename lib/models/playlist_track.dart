class PlaylistTracksData {
  final List<PlaylistTrack> tracks;
  final Links links;
  final Meta meta;

  PlaylistTracksData({
    required this.tracks,
    required this.links,
    required this.meta,
  });

  factory PlaylistTracksData.fromJson(Map<String, dynamic> json) {
    return PlaylistTracksData(
      tracks: ((json['tracks'] as List?) ?? [])
          .map((e) => PlaylistTrack.fromJson(e))
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

class PlaylistTrack {
  final String id;
  final AnimeThemeEntry animethemeentry;
  final Video video;

  PlaylistTrack({
    required this.id,
    required this.animethemeentry,
    required this.video,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    return PlaylistTrack(
      id: json['id'] ?? '',
      animethemeentry: AnimeThemeEntry.fromJson(json['animethemeentry'] ?? {}),
      video: Video.fromJson(json['video'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animethemeentry': animethemeentry.toJson(),
      'video': video.toJson(),
    };
  }
}

class AnimeThemeEntry {
  final int id;
  final String episodes;
  final String? notes;
  final bool nsfw;
  final bool spoiler;
  final int version;
  final AnimeTheme animetheme;

  AnimeThemeEntry({
    required this.id,
    required this.episodes,
    this.notes,
    required this.nsfw,
    required this.spoiler,
    required this.version,
    required this.animetheme,
  });

  factory AnimeThemeEntry.fromJson(Map<String, dynamic> json) {
    return AnimeThemeEntry(
      id: json['id'] ?? 0,
      episodes: json['episodes'] ?? '',
      notes: json['notes'],
      nsfw: json['nsfw'] ?? false,
      spoiler: json['spoiler'] ?? false,
      version: json['version'] ?? 0,
      animetheme: AnimeTheme.fromJson(json['animetheme'] ?? {}),
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
      'animetheme': animetheme.toJson(),
    };
  }
}

class AnimeTheme {
  final int id;
  final int? sequence;
  final String slug;
  final String type;
  final Anime anime;
  final Song song;

  AnimeTheme({
    required this.id,
    this.sequence,
    required this.slug,
    required this.type,
    required this.anime,
    required this.song,
  });

  factory AnimeTheme.fromJson(Map<String, dynamic> json) {
    return AnimeTheme(
      id: json['id'] ?? 0,
      sequence: json['sequence'],
      slug: json['slug'] ?? '',
      type: json['type'] ?? '',
      anime: Anime.fromJson(json['anime'] ?? {}),
      song: Song.fromJson(json['song'] ?? {}),
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

class Anime {
  final int id;
  final String name;
  final String mediaFormat;
  final String season;
  final String slug;
  final String synopsis;
  final int year;
  final List<AnimeImage> images;

  Anime({
    required this.id,
    required this.name,
    required this.mediaFormat,
    required this.season,
    required this.slug,
    required this.synopsis,
    required this.year,
    required this.images,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    var imageList = <AnimeImage>[];
    if (json['images'] != null) {
      imageList = List<AnimeImage>.from(
        (json['images'] as List).map((x) => AnimeImage.fromJson(x)),
      );
    }

    return Anime(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mediaFormat: json['media_format'] ?? '',
      season: json['season'] ?? '',
      slug: json['slug'] ?? '',
      synopsis: json['synopsis'] ?? '',
      year: json['year'] ?? 0,
      images: imageList,
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
      'images': images.map((x) => x.toJson()).toList(),
    };
  }
}

class AnimeImage {
  final int id;
  final String facet;
  final String path;
  final String link;

  AnimeImage({
    required this.id,
    required this.facet,
    required this.path,
    required this.link,
  });

  factory AnimeImage.fromJson(Map<String, dynamic> json) {
    return AnimeImage(
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

class Song {
  final int id;
  final String title;
  final List<Artist> artists;

  Song({
    required this.id,
    required this.title,
    required this.artists,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    var artistList = <Artist>[];
    if (json['artists'] != null) {
      artistList = List<Artist>.from(
        (json['artists'] as List).map((x) => Artist.fromJson(x)),
      );
    }

    return Song(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      artists: artistList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artists': artists.map((x) => x.toJson()).toList(),
    };
  }
}

class Artist {
  final int id;
  final String name;
  final String slug;
  final String? information;

  Artist({
    required this.id,
    required this.name,
    required this.slug,
    this.information,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
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

class Video {
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
  final Audio audio;

  Video({
    required this.id,
    required this.basename,
    required this.filename,
    required this.lyrics,
    required this.nc,
    this.overlap,
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
      currentPage: json['current_page'] ?? 1,
      currentPageUrl: json['current_page_url'] ?? '',
      from: json['from'] ?? 1,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 50,
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
