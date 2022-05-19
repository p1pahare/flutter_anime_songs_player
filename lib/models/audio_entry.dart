class AudioEntry {
  AudioEntry(
      {required this.album,
      required this.title,
      required this.url,
      required String urld}) {
    if (urld.isNotEmpty) {
      art = Uri.parse(urld);
    }
  }
  late final String album;
  late final String title;
  late final String url;
  Uri art = Uri.file('lib/assets/cover.jpg');

  AudioEntry.fromJson(Map<String, dynamic> json) {
    album = json['album'];
    title = json['title'];
    url = json['url'];
    art = json['art'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['album'] = album;
    _data['title'] = title;
    _data['url'] = url;
    _data['art'] = art;
    return _data;
  }
}
