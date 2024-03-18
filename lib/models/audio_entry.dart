class AudioEntry {
  AudioEntry(
      {required this.id,
      required this.album,
      required this.title,
      required this.audioUrl,
      required this.videoUrl,
      required this.urlCover}) {
    if (urlCover?.isNotEmpty ?? false) {
      art = Uri.parse(urlCover!);
    }
  }
  late final String id;
  late final String album;
  late final String title;
  late final String? audioUrl;
  late final String? videoUrl;
  late final String? urlCover;
  Uri art = Uri.parse(
      'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj5REg76Q_U_rt-GxBXbi3C-76wOIKdcuGwl1PMOBoMkpdNva48wiHny2t2tCH2lFeh4GNCNrLlcXrx3mHH_V0vSwSPN9zG2iyUmmvuZbgbtjLsZ1FO6mOhmfuqUD54Uti8ieIXdTPi3ZbZDJzJxrv70pRah8g_rzLlb49JSWuUGfB2I7DdCTgiCdh9_A/s320/cover.jpg');

  AudioEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    album = json['album'];
    title = json['title'];
    audioUrl = json['audioUrl'];
    urlCover = json['urlCover'];
    videoUrl = json['videoUrl'];
    art = Uri.parse(json['art']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['album'] = album;
    _data['title'] = title;
    _data['audioUrl'] = audioUrl;
    _data['urlCover'] = urlCover;
    _data['videoUrl'] = videoUrl;
    _data['art'] = art.toString();
    return _data;
  }
}
