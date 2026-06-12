// playlists_response.dart

class PlaylistsResponse {
  final List<Playlist> playlists;
  final Links links;
  final Meta meta;

  PlaylistsResponse({
    required this.playlists,
    required this.links,
    required this.meta,
  });

  factory PlaylistsResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistsResponse(
      playlists: ((json['playlists'] as List?) ?? [])
          .map((e) => Playlist.fromJson(e))
          .toList(),
      links: Links.fromJson(json['links'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlists': playlists.map((e) => e.toJson()).toList(),
      'links': links.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class Playlist {
  final String id;
  final String name;
  final String? description;
  final String visibility;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.visibility,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      visibility: json['visibility'] ?? 'PRIVATE',
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