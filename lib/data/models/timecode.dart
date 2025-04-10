class Timecode {
  final String releaseEpisodeId;
  final bool isWatched;
  final int time;

  Timecode({
    required this.time,
    required this.isWatched,
    required this.releaseEpisodeId,
  });

  factory Timecode.fromJson(List<dynamic> json) =>
      Timecode(releaseEpisodeId: json[0], time: json[1], isWatched: json[2]);
  Map<String, dynamic> toJson() => {
    'release_episode_id': releaseEpisodeId,
    'time': time,
    'is_watched': isWatched,
  };
}
