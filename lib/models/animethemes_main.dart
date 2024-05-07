class AnimethemesMain {
  AnimethemesMain({
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
  late final Anime anime;
  late final Song song;
  late final List<Animethemeentries> animethemeentries;

  AnimethemesMain.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    sequence = json['sequence'] ?? 0;
    group = json['group']?.toString() ?? '';
    slug = json['slug'];
    anime = Anime.fromJson(json['anime']);
    song = Song.fromJson(json['song']);
    animethemeentries = List.from(json['animethemeentries'])
        .map((e) => Animethemeentries.fromJson(e))
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
}

class Anime {
  Anime({
    required this.name,
    required this.slug,
    required this.year,
    required this.season,
    required this.images,
  });
  late final String name;
  late final String slug;
  late final int year;
  late final String season;
  late final List<Images> images;

  Anime.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    year = json['year'];
    season = json['season'];
    images = List.from(json['images']).map((e) => Images.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['slug'] = slug;
    _data['year'] = year;
    _data['season'] = season;
    _data['images'] = images.map((e) => e.toJson()).toList();
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

class Artists {
  Artists({
    required this.name,
    required this.slug,
    required this.as,
  });
  late final String name;
  late final String slug;
  late final String as;

  Artists.fromJson(Map<String, dynamic> json) {
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

class Animethemeentries {
  Animethemeentries({
    required this.version,
    required this.videos,
  });
  late final int version;
  late final List<Videos> videos;

  Animethemeentries.fromJson(Map<String, dynamic> json) {
    version = int.tryParse(json['version']?.toString() ?? '0') ?? 0;
    videos = List.from(json['videos']).map((e) => Videos.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['version'] = version;
    _data['videos'] = videos.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Videos {
  Videos({
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
  late final Audio audio;

  Videos.fromJson(Map<String, dynamic> json) {
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
      audio = Audio.fromJson(json['audio']);
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

class Audio {
  Audio({
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

  Audio.fromJson(Map<String, dynamic> json) {
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
