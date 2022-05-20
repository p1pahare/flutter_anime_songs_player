import 'package:anime_themes_player/models/anime_main.dart';

class Seasons {
  Seasons({
    required this.winter,
    required this.spring,
    required this.summer,
    required this.fall,
  });
  late final List<AnimeMain> winter;
  late final List<AnimeMain> spring;
  late final List<AnimeMain> summer;
  late final List<AnimeMain> fall;

  Seasons.fromJson(Map<String, dynamic> json) {
    winter = List.from(json['winter'] ?? [])
        .map((e) => AnimeMain.fromJson(e))
        .toList();
    spring = List.from(json['spring'] ?? [])
        .map((e) => AnimeMain.fromJson(e))
        .toList();
    summer = List.from(json['summer'] ?? [])
        .map((e) => AnimeMain.fromJson(e))
        .toList();
    fall = List.from(json['fall'] ?? [])
        .map((e) => AnimeMain.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['winter'] = winter.map((e) => e.toJson()).toList();
    _data['spring'] = spring.map((e) => e.toJson()).toList();
    _data['summer'] = summer.map((e) => e.toJson()).toList();
    _data['fall'] = fall.map((e) => e.toJson()).toList();
    return _data;
  }
}
