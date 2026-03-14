import 'package:anime_themes_player/models/anime.dart';
import 'package:anime_themes_player/models/animethemes.dart';

class AudioEntry {
  AudioEntry(
      {required this.id,
      required this.album,
      required this.title,
      required this.audioUrl,
      required this.videoUrl,
      required this.artist,
      required this.urlCover}) {
    if (urlCover?.isNotEmpty ?? false) {
      art = Uri.parse(urlCover!);
    }
  }
  late final String id;
  late final String album;
  late final String title;
  late final String artist;
  late final String? audioUrl;
  late final String? videoUrl;
  late final String? urlCover;
  Uri art = Uri.parse(
      'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj5REg76Q_U_rt-GxBXbi3C-76wOIKdcuGwl1PMOBoMkpdNva48wiHny2t2tCH2lFeh4GNCNrLlcXrx3mHH_V0vSwSPN9zG2iyUmmvuZbgbtjLsZ1FO6mOhmfuqUD54Uti8ieIXdTPi3ZbZDJzJxrv70pRah8g_rzLlb49JSWuUGfB2I7DdCTgiCdh9_A/s320/cover.jpg');

  AudioEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    album = json['album'];
    title = json['title'];
    artist = json['artist'];
    audioUrl = json['audioUrl'];
    urlCover = json['urlCover'];
    videoUrl = json['videoUrl'];
    art = Uri.parse(json['art']);
  }


  AudioEntry.fromThemeEntry(Animethemes albumModel, AtmAnimethemeentries entryModel) {
     
    id = entryModel.videos.first.id.toString();
    album = albumModel.getTitle();
    title = albumModel.song.title;
    artist = albumModel.song.artists.map((artst) => artst.name).join(",");
    audioUrl = entryModel.videos.first.audio.link;
    urlCover = albumModel.getImageUrl();
    videoUrl = entryModel.videos.first.link;
    if(urlCover?.isNotEmpty ?? false) {
      art = Uri.parse(urlCover!);
     }
  }

  AudioEntry.fromThemeEntryV2(Anime? animeMain, AmAnimethemes albumModel, AmAnimethemeentries entryModel) {
     
    id = entryModel.videos.first.id.toString();
    album = animeMain?.getTitle().toString()??'';
    title = albumModel.song?.title??'';
    artist = albumModel.song?.artists.map((artst) => artst.name).join(",")??'';
    audioUrl = entryModel.videos.first.audio.link;
    urlCover = animeMain?.getImageUrl()??'';
    videoUrl = entryModel.videos.first.link;
    if(urlCover?.isNotEmpty ?? false) {
      art = Uri.parse(urlCover!);
     }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['album'] = album;
    _data['title'] = title;
    _data['artist'] = artist;
    _data['audioUrl'] = audioUrl;
    _data['urlCover'] = urlCover;
    _data['videoUrl'] = videoUrl;
    _data['art'] = art.toString();
    return _data;
  }
}
