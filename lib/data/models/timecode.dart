class Timecode {
  final String releaseEpisodeId;
  final bool isWatched;
  final int time;

  Timecode({
    required this.time,
    required this.isWatched,
    required this.releaseEpisodeId,
  });
  Map<String, dynamic> toJson() => {
    'release_episode_id': releaseEpisodeId,
    'time': time,
    'is_watched': isWatched,
  };
  factory Timecode.fromJsonList(List<dynamic> json) =>
      Timecode(releaseEpisodeId: json[0], time: json[1], isWatched: json[2]);

  factory Timecode.fromJsonMap(Map<String, dynamic> json) => Timecode(
    releaseEpisodeId: json['release_episode_id'],
    time: json['time'],
    isWatched: json['is_watched'],
  );
}
