import 'package:anime_themes_player/models/animethemes_main.dart';

class AnimeMain {
  AnimeMain(
      {required this.name,
      required this.slug,
      required this.year,
      required this.season,
      required this.animethemes,
      required this.resources,
      required this.images,
      required this.studios});
  late final String name;
  late final String slug;
  late final int year;
  late final String season;
  late final List<Animethemes> animethemes;
  late final List<Resources> resources;
  late final List<Images> images;
  late final List<Studios> studios;

  AnimeMain.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    year = json['year'];
    season = json['season'];
    animethemes = List.from(json['animethemes'] ?? [])
        .map((e) => Animethemes.fromJson(e))
        .toList();
    resources = List.from(json['resources'] ?? [])
        .map((e) => Resources.fromJson(e))
        .toList();
    studios = List.from(json['studios'] ?? [])
        .map((e) => Studios.fromJson(e))
        .toList();
    images =
        List.from(json['images'] ?? []).map((e) => Images.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['slug'] = slug;
    _data['year'] = year;
    _data['season'] = season;
    _data['animethemes'] = animethemes.map((e) => e.toJson()).toList();
    _data['resources'] = resources.map((e) => e.toJson()).toList();
    _data['studios'] = studios.map((e) => e.toJson()).toList();
    _data['images'] = images.map((e) => e.toJson()).toList();

    return _data;
  }
}

class Animethemes {
  Animethemes({
    required this.type,
    required this.sequence,
    required this.group,
    required this.slug,
    required this.song,
    required this.animethemeentries,
  });
  late final String type;
  late final int? sequence;
  late final String group;
  late final String slug;
  late final Song song;
  late final List<Animethemeentries> animethemeentries;

  Animethemes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    sequence = int.tryParse(json['sequence']?.toString() ?? '0');
    group = json['group']?.toString() ?? '';
    slug = json['slug'];
    song = Song.fromJson(json['song']);
    animethemeentries = List.from(json['animethemeentries'])
        .map((e) => Animethemeentries.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['type'] = type;
    _data['sequence'] = sequence;
    _data['group'] = group;
    _data['slug'] = slug;
    _data['song'] = song.toJson();
    _data['animethemeentries'] =
        animethemeentries.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Song {
  Song({
    required this.title,
    required this.artists,
  });
  late final String title;
  late final List<Artists> artists;

  Song.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    artists =
        List.from(json['artists']).map((e) => Artists.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['title'] = title;
    _data['artists'] = artists.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Animethemeentries {
  Animethemeentries({
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
  late final List<Videos> videos;

  Animethemeentries.fromJson(Map<String, dynamic> json) {
    version = int.tryParse(json['version']?.toString() ?? '0');
    episodes = json['episodes']?.toString() ?? '';
    nsfw = json['nsfw'] ?? false;
    spoiler = json['spoiler'] ?? false;
    videos = List.from(json['videos']).map((e) => Videos.fromJson(e)).toList();
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

class Videos {
  Videos({
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

  Videos.fromJson(Map<String, dynamic> json) {
    resolution = json['resolution'] ?? 0;
    nc = json['nc'] ?? false;
    subbed = json['subbed'] ?? false;
    lyrics = json['lyrics'] ?? false;
    uncen = json['uncen'] ?? false;
    source = json['source']?.toString() ?? '';
    overlap = json['overlap'] ?? '';
    tags = json['tags'];
    link = json['link'];
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
    return _data;
  }
}

class Resources {
  Resources({
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

  Resources.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    link = json['link'];
    externalId = json['external_id'];
    site = json['site'];
    as = json['as']?.toString() ?? '';
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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

class Images {
  Images({
    required this.facet,
    required this.link,
  });
  late final String facet;
  late final String link;

  Images.fromJson(Map<String, dynamic> json) {
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

class Studios {
  Studios({
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

  Studios.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
