class ResourcesMain {
  ResourcesMain({
    required this.id,
    required this.link,
    required this.externalId,
    required this.site,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.anime,
  });
  late final int id;
  late final String link;
  late final int externalId;
  late final String site;
  late final String createdAt;
  late final String updatedAt;
  late final String deletedAt;
  late final List<Anime> anime;

  ResourcesMain.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    link = json['link'] ?? '';
    externalId = json['external_id'] ?? '';
    site = json['site'] ?? '';
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    deletedAt = json['deleted_at']?.toString() ?? '';
    anime = List.from(json['anime']).map((e) => Anime.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['link'] = link;
    _data['external_id'] = externalId;
    _data['site'] = site;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['deleted_at'] = deletedAt;
    _data['anime'] = anime.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Anime {
  Anime({
    required this.id,
    required this.name,
    required this.slug,
    required this.year,
    required this.season,
    required this.synopsis,
    required this.createdAt,
    required this.updatedAt,
  });
  late final int id;
  late final String name;
  late final String slug;
  late final int year;
  late final String season;
  late final String synopsis;
  late final String createdAt;
  late final String updatedAt;

  Anime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    year = json['year'];
    season = json['season'];
    synopsis = json['synopsis'] ?? '';
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['slug'] = slug;
    _data['year'] = year;
    _data['season'] = season;
    _data['synopsis'] = synopsis;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}
