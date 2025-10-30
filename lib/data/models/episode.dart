class PreviewEpisode {
  final String id;
  final int ordinal;
  final bool isDubbed;
  final bool isSubbed;
  final String title;

  PreviewEpisode({
    required this.id,
    required this.ordinal,
    required this.isDubbed,
    required this.isSubbed,
    required this.title,
  });

  factory PreviewEpisode.fromJson(Map<String, dynamic> json) {
    return PreviewEpisode(
      id: json['id'],
      isDubbed: json['is_dubbed'],
      isSubbed: json['is_subbed'],
      ordinal: json['ordinal'],
      title: json['title'],
    );
  }
}

class TimeSegment {
  final int start;
  final int end;

  TimeSegment({required this.start, required this.end});

  factory TimeSegment.fromJson(Map<String, dynamic> json) {
    return TimeSegment(start: json['start'], end: json['end']);
  }
}

class Source {
  final String url;
  final String type;

  Source({required this.url, required this.type});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(url: json['url'], type: json['type']);
  }
}

class Subtitle {
  final String vtt;
  final String language;

  Subtitle({required this.vtt, required this.language});

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    return Subtitle(vtt: json['url'], language: json['lang']);
  }
}

class Episode {
  final String id;
  final int ordinal;
  final bool isDubbed;
  final String title;
  final TimeSegment opening;
  final TimeSegment ending;
  final List<Source> sources;
  final List<Subtitle>? subtitles;

  Episode({
    required this.id,
    required this.isDubbed,
    required this.ordinal,
    required this.title,
    required this.opening,
    required this.ending,
    required this.sources,
    this.subtitles,
  });

  factory Episode.fromJson(Map<String, dynamic> json, isDubbed) {
    var result = json['result'];
    return Episode(
      id: result['id'],
      isDubbed: isDubbed,
      ordinal: result['ordinal'],
      title: result['title'],
      opening: TimeSegment.fromJson(result['opening']),
      ending: TimeSegment.fromJson(result['ending']),
      sources:
          (result['sources'] as List<dynamic>)
              .map((e) => Source.fromJson(e))
              .toList(),
      subtitles:
          (result['subtitles'] as List<dynamic>?)
              ?.map((e) => Subtitle.fromJson(e))
              .toList(),
    );
  }
}
