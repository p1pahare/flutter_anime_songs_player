import 'package:anime_themes_player/models/animethemes.dart';
import 'package:anime_themes_player/models/theme_album.dart';
import 'package:anime_themes_player/utilities/values.dart';

class Anime implements ThemeAlbum {
  Anime(
      {required this.name,
      required this.slug,
      required this.year,
      required this.season,
      required this.animethemes,
      required this.resources,
      required this.images,
      required this.synopsis,
      required this.mediaFormat,
      required this.studios});
  late final String name;
  late final String slug;
  late final int year;
  late final String season;
  late final String mediaFormat;
  late final String synopsis;
  late final List<AmAnimethemes> animethemes;
  late final List<AmResources> resources;
  late final List<AmImages> images;
  late final List<AmStudios> studios;

  Anime.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    year = json['year'];
    season = json['season'];
    mediaFormat = json['media_format'] ?? "";
    synopsis = json['synopsis'] ?? "";
    animethemes = List.from(json['animethemes'] ?? [])
        .map((e) => AmAnimethemes.fromJson(e))
        .toList();
    resources = List.from(json['resources'] ?? [])
        .map((e) => AmResources.fromJson(e))
        .toList();
    studios = List.from(json['studios'] ?? [])
        .map((e) => AmStudios.fromJson(e))
        .toList();
    images = List.from(json['images'] ?? [])
        .map((e) => AmImages.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['slug'] = slug;
    _data['year'] = year;
    _data['season'] = season;
    _data['media_format'] = mediaFormat;
    _data['synopsis'] = synopsis;
    _data['animethemes'] = animethemes.map((e) => e.toJson()).toList();
    _data['resources'] = resources.map((e) => e.toJson()).toList();
    _data['studios'] = studios.map((e) => e.toJson()).toList();
    _data['images'] = images.map((e) => e.toJson()).toList();

    return _data;
  }

  @override
  List items() {
    List<MapEntry<AmAnimethemes, AmAnimethemeentries>> themes = [];
    for (final at in animethemes) {
      for (final ate in at.animethemeentries) {
        themes.add(MapEntry(at, ate));
      }
    }
    return themes;
  }

  @override
  String getImageUrl() {
    return images
        .firstWhere((img) => img.facet == Values.largeCover,
            orElse: () => images.first)
        .link;
  }

  @override
  String getRelease() {
    return "${season.isEmpty ? '??' : season}/${year < 1940 ? '??' : year}";
  }

  @override
  String getStudio() {
    String studs = "";
    for (int s = 0; s < studios.length; s++) {
      studs += studios[s].name;
      if (s != studios.length - 1) {
        studs += ", ";
      }
    }
    return studs;
  }

  @override
  String getTitle() {
    return name;
  }

  @override
  String getSynopsis() {
    return synopsis.replaceAll('<br>\n', ' ');
  }
}

class AmAnimethemes {
  AmAnimethemes({
    required this.type,
    required this.sequence,
    required this.group,
    required this.slug,
    required this.song,
    required this.id,
    required this.animethemeentries,
  });
  late final int id;
  late final String type;
  late final int? sequence;
  late final String group;
  late final String slug;
  late final AmSong? song;
  late final List<AmAnimethemeentries> animethemeentries;

  AmAnimethemes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    sequence = int.tryParse(json['sequence']?.toString() ?? '0');
    group = json['group']?.toString() ?? '';
    slug = json['slug'];
    song = json['song'] != null ? AmSong.fromJson(json['song']) : null;

    animethemeentries = List.from(json['animethemeentries'])
        .map((e) => AmAnimethemeentries.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['type'] = type;
    _data['sequence'] = sequence;
    _data['group'] = group;
    _data['slug'] = slug;
    _data['song'] = song?.toJson();
    _data['animethemeentries'] =
        animethemeentries.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AmSong {
  AmSong({
    required this.title,
    required this.artists,
  });
  late final String title;
  late final List<AtmArtists> artists;

  AmSong.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    artists = List.from(json['artists'] ?? [])
        .map((e) => AtmArtists.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['title'] = title;
    _data['artists'] = artists.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AmAnimethemeentries {
  AmAnimethemeentries({
    this.version,
    required this.episodes,
    required this.nsfw,
    required this.spoiler,
    required this.videos,
  });
  late final int? version;
  late final String episodes;
  late final bool nsfw;
  late final bool spoiler;
  late final List<AmVideos> videos;

  AmAnimethemeentries.fromJson(Map<String, dynamic> json) {
    version = int.tryParse(json['version']?.toString() ?? '0');
    episodes = json['episodes']?.toString() ?? '';
    nsfw = json['nsfw'] ?? false;
    spoiler = json['spoiler'] ?? false;
    videos = List.from(json['videos'] ?? [])
        .map((e) => AmVideos.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['version'] = version;
    _data['episodes'] = episodes;
    _data['nsfw'] = nsfw;
    _data['spoiler'] = spoiler;
    _data['videos'] = videos.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AmVideos {
  AmVideos({
    required this.resolution,
    required this.nc,
    required this.subbed,
    required this.lyrics,
    required this.uncen,
    required this.source,
    required this.overlap,
    required this.tags,
    required this.link,
  });
  late final int resolution;
  late final bool nc;
  late final bool subbed;
  late final bool lyrics;
  late final bool uncen;
  late final String source;
  late final String overlap;
  late final String tags;
  late final String link;
  late final AmAudio audio;

  AmVideos.fromJson(Map<String, dynamic> json) {
    resolution = json['resolution'] ?? 0;
    nc = json['nc'] ?? false;
    subbed = json['subbed'] ?? false;
    lyrics = json['lyrics'] ?? false;
    uncen = json['uncen'] ?? false;
    source = json['source']?.toString() ?? '';
    overlap = json['overlap'] ?? '';
    tags = json['tags'];
    link = json['link'];
    audio = AmAudio.fromJson(json['audio']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['resolution'] = resolution;
    _data['nc'] = nc;
    _data['subbed'] = subbed;
    _data['lyrics'] = lyrics;
    _data['uncen'] = uncen;
    _data['source'] = source;
    _data['overlap'] = overlap;
    _data['tags'] = tags;
    _data['link'] = link;
    _data['audio'] = audio.toJson();
    return _data;
  }
}

class AmAudio {
  AmAudio({
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

  AmAudio.fromJson(Map<String, dynamic> json) {
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

class AmResources {
  AmResources({
    required this.id,
    required this.link,
    required this.externalId,
    required this.site,
    required this.as,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });
  late final int id;
  late final String link;
  late final int externalId;
  late final String site;
  late final String as;
  late final String createdAt;
  late final String updatedAt;
  late final String deletedAt;

  AmResources.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    link = json['link'];
    externalId = json['external_id'] ?? 0;
    site = json['site'];
    as = json['as']?.toString() ?? '';
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    deletedAt = json['deleted_at']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['link'] = link;
    _data['external_id'] = externalId;
    _data['site'] = site;
    _data['as'] = as;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['deleted_at'] = deletedAt;
    return _data;
  }
}

class AmImages {
  AmImages({
    required this.facet,
    required this.link,
  });
  late final String facet;
  late final String link;

  AmImages.fromJson(Map<String, dynamic> json) {
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

class AmStudios {
  AmStudios({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });
  late final int id;
  late final String name;
  late final String slug;
  late final String createdAt;
  late final String updatedAt;
  late final String deletedAt;

  AmStudios.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    deletedAt = json['deleted_at']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['slug'] = slug;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['deleted_at'] = deletedAt;
    return _data;
  }
}
