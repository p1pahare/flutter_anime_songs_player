import 'package:anime_themes_player/models/theme_album.dart';
import 'package:anime_themes_player/utilities/values.dart';

class Animethemes implements ThemeAlbum {
  Animethemes({
    required this.id,
    required this.type,
    required this.sequence,
    required this.group,
    required this.slug,
    required this.anime,
    required this.song,
    required this.animethemeentries,
  });
  late final int id;
  late final String type;
  late final int sequence;
  late final String group;
  late final String slug;
  late final AtmAnime anime;
  late final AtmSong song;
  late final List<AtmAnimethemeentries> animethemeentries;

  Animethemes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    sequence = json['sequence'] ?? 0;
    group = json['group']?.toString() ?? '';
    slug = json['slug'];
    anime = AtmAnime.fromJson(json['anime']);
    song = AtmSong.fromJson(json['song']);
    animethemeentries = List.from(json['animethemeentries'])
        .map((e) => AtmAnimethemeentries.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['type'] = type;
    _data['sequence'] = sequence;
    _data['group'] = group;
    _data['slug'] = slug;
    _data['anime'] = anime.toJson();
    _data['song'] = song.toJson();
    _data['animethemeentries'] =
        animethemeentries.map((e) => e.toJson()).toList();
    return _data;
  }

  @override
  List items() {
    return animethemeentries;
  }

  @override
  String getImageUrl() {
    return anime.images
        .firstWhere((img) => img.facet == Values.largeCover,
            orElse: () => anime.images.first)
        .link;
  }

  @override
  String getRelease() {
    return "${anime.season.isEmpty ? '??' : anime.season}/${anime.year < 1940 ? '??' : anime.year}";
  }

  @override
  String getStudio() {
    String studs = "";
    // for (int s = 0; s < anime.studios.length; s++) {
    //   studs += anime.studios[s].name;
    //   if (s != studios.length - 1) {
    //     studs += ", ";
    //   }
    // }
    return studs;
  }

  @override
  String getTitle() {
    return anime.name;
  }

  @override
  String getSynopsis() {
    return anime.synopsis;
  }
}

class AtmAnime {
  AtmAnime({
    required this.name,
    required this.slug,
    required this.year,
    required this.season,
    required this.images,
    required this.synopsis,
    required this.mediaFormat,
  });
  late final String name;
  late final String slug;
  late final int year;
  late final String mediaFormat;
  late final String synopsis;
  late final String season;
  late final List<AtmImages> images;

  AtmAnime.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    year = json['year'];
    season = json['season'];
    mediaFormat = json['media_format'] ?? "";
    synopsis = json['synopsis'] ?? "";
    images =
        List.from(json['images']).map((e) => AtmImages.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['slug'] = slug;
    _data['year'] = year;
    _data['media_format'] = mediaFormat;
    _data['synopsis'] = synopsis;
    _data['season'] = season;
    _data['images'] = images.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AtmImages {
  AtmImages({
    required this.facet,
    required this.link,
  });
  late final String facet;
  late final String link;

  AtmImages.fromJson(Map<String, dynamic> json) {
    facet = json['facet'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['facet'] = facet;
    _data['link'] = link;
    return _data;
  }
}

class AtmSong {
  AtmSong({
    required this.title,
    required this.artists,
  });
  late final String title;
  late final List<AtmArtists> artists;

  AtmSong.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    artists =
        List.from(json['artists']).map((e) => AtmArtists.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['title'] = title;
    _data['artists'] = artists.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AtmArtists {
  AtmArtists({
    required this.name,
    required this.slug,
    required this.as,
  });
  late final String name;
  late final String slug;
  late final String as;

  AtmArtists.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    as = json['as'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['slug'] = slug;
    _data['as'] = as;
    return _data;
  }
}

class AtmAnimethemeentries {
  AtmAnimethemeentries({
    required this.version,
    required this.videos,
  });
  late final int version;
  late final List<AtmVideos> videos;

  AtmAnimethemeentries.fromJson(Map<String, dynamic> json) {
    version = int.tryParse(json['version']?.toString() ?? '0') ?? 0;
    videos =
        List.from(json['videos']).map((e) => AtmVideos.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['version'] = version;
    _data['videos'] = videos.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AtmVideos {
  AtmVideos({
    required this.id,
    required this.basename,
    required this.filename,
    required this.path,
    required this.size,
    required this.mimetype,
    required this.resolution,
    required this.nc,
    required this.subbed,
    required this.lyrics,
    required this.uncen,
    required this.source,
    required this.overlap,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.tags,
    required this.link,
    required this.audio,
  });
  late final int? id;
  late final String? basename;
  late final String filename;
  late final String? path;
  late final int? size;
  late final String? mimetype;
  late final int? resolution;
  late final bool? nc;
  late final bool? subbed;
  late final bool? lyrics;
  late final bool? uncen;
  late final String? source;
  late final String? overlap;
  late final String? createdAt;
  late final String? updatedAt;
  late final String? deletedAt;
  late final String? tags;
  late final String link;
  late final AtmAudio audio;

  AtmVideos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    basename = json['basename'];
    filename = json['filename'];
    path = json['path'];
    size = json['size'];
    mimetype = json['mimetype'];
    resolution = json['resolution'];
    nc = json['nc'];
    subbed = json['subbed'];
    lyrics = json['lyrics'];
    uncen = json['uncen'];
    source = json['source'];
    overlap = json['overlap'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    tags = json['tags'];
    link = json['link'];
    if (json['audio'] != null) {
      audio = AtmAudio.fromJson(json['audio']);
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['basename'] = basename;
    _data['filename'] = filename;
    _data['path'] = path;
    _data['size'] = size;
    _data['mimetype'] = mimetype;
    _data['resolution'] = resolution;
    _data['nc'] = nc;
    _data['subbed'] = subbed;
    _data['lyrics'] = lyrics;
    _data['uncen'] = uncen;
    _data['source'] = source;
    _data['overlap'] = overlap;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['deleted_at'] = deletedAt;
    _data['tags'] = tags;
    _data['link'] = link;
    _data['audio'] = audio.toJson();
    return _data;
  }
}

class AtmAudio {
  AtmAudio({
    required this.id,
    required this.basename,
    required this.filename,
    required this.path,
    required this.size,
    required this.link,
  });
  late final int id;
  late final String basename;
  late final String filename;
  late final String path;
  late final int size;
  late final String link;

  AtmAudio.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    basename = json['basename'];
    filename = json['filename'];
    path = json['path'];
    size = json['size'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['basename'] = basename;
    _data['filename'] = filename;
    _data['path'] = path;
    _data['size'] = size;
    _data['link'] = link;
    return _data;
  }
}
