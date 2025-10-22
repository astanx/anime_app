class Timecode {
  final String episodeID;
  final bool isWatched;
  final String animeID;
  final int time;

  Timecode({
    required this.time,
    required this.isWatched,
    required this.episodeID,
    required this.animeID,
  });
  factory Timecode.fromJson(Map<String, dynamic> json) => Timecode(
    episodeID: json['episode_id'],
    time: json['time'],
    isWatched: json['is_watched'],
    animeID: json['anime_id'],
  );
  static List<Timecode> fromJsonList(List<dynamic> json) {
    List<Timecode> timecodes =
        json.map((e) => Timecode.fromJson(e as Map<String, dynamic>)).toList();
    return timecodes;
  }
}
