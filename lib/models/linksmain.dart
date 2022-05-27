class LinksMain {
  LinksMain({
    required this.first,
    required this.last,
    required this.prev,
    required this.next,
  });
  late final String? first;
  late final String? last;
  late final String? prev;
  late final String? next;

  LinksMain.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['first'] = first;
    _data['last'] = last;
    _data['prev'] = prev;
    _data['next'] = next;
    return _data;
  }
}
