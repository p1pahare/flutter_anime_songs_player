class DemoCat {
  DemoCat({
    required this.breeds,
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });
  late final List<dynamic> breeds;
  late final String id;
  late final String url;
  late final String width;
  late final String height;

  DemoCat.fromJson(Map<String, dynamic> json) {
    breeds = List.castFrom<dynamic, dynamic>(json['breeds']);
    id = json['id'];
    url = json['url'];
    width = json['width'].toString();
    height = json['height'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['breeds'] = breeds;
    _data['id'] = id;
    _data['url'] = url;
    _data['width'] = width;
    _data['height'] = height;
    return _data;
  }
}
