class AnithemesMain {
  AnithemesMain({
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

  AnithemesMain.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    sequence = json['sequence'];
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
    as = json['as'];
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
  late final String version;
  late final List<Videos> videos;

  Animethemeentries.fromJson(Map<String, dynamic> json) {
    version = json['version']?.toString() ?? '';
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
    required this.tags,
    required this.link,
  });
  late final String tags;
  late final String link;

  Videos.fromJson(Map<String, dynamic> json) {
    tags = json['tags'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['tags'] = tags;
    _data['link'] = link;
    return _data;
  }
}
