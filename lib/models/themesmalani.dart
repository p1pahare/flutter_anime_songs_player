class ThemesMALANI {
  ThemesMALANI({
    required this.malID,
    required this.name,
    required this.score,
    required this.season,
    required this.themes,
    required this.watchStatus,
    required this.year,
  });
  late final int malID;
  late final String name;
  late final int score;
  late final String season;
  late final List<Themes> themes;
  late final int watchStatus;
  late final int year;

  ThemesMALANI.fromJson(Map<String, dynamic> json) {
    malID = json['malID'];
    name = json['name'];
    score = json['score'];
    season = json['season'];
    themes = List.from(json['themes']).map((e) => Themes.fromJson(e)).toList();
    watchStatus = json['watchStatus'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['malID'] = malID;
    _data['name'] = name;
    _data['score'] = score;
    _data['season'] = season;
    _data['themes'] = themes.map((e) => e.toJson()).toList();
    _data['watchStatus'] = watchStatus;
    _data['year'] = year;
    return _data;
  }
}

class Themes {
  Themes({
    required this.mirror,
    required this.themeName,
    required this.themeType,
  });
  late final Mirror mirror;
  late final String themeName;
  late final String themeType;

  Themes.fromJson(Map<String, dynamic> json) {
    mirror = Mirror.fromJson(json['mirror']);
    themeName = json['themeName'];
    themeType = json['themeType'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['mirror'] = mirror.toJson();
    _data['themeName'] = themeName;
    _data['themeType'] = themeType;
    return _data;
  }
}

class Mirror {
  Mirror({
    required this.mirrorURL,
    required this.notes,
    required this.priority,
  });
  late final String mirrorURL;
  late final String notes;
  late final int priority;

  Mirror.fromJson(Map<String, dynamic> json) {
    mirrorURL = json['mirrorURL'];
    notes = json['notes'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['mirrorURL'] = mirrorURL;
    _data['notes'] = notes;
    _data['priority'] = priority;
    return _data;
  }
}
