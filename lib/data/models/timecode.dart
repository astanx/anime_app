class Timecode {
  final String releaseEpisodeId;
  final bool isWatched;
  final int time;

  Timecode({
    required this.time,
    required this.isWatched,
    required this.releaseEpisodeId,
  });

  factory Timecode.fromJson(Map<String, dynamic> json) => Timecode(
    releaseEpisodeId: json['release_episode_id'],
    time: json['time'],
    isWatched: json['is_watched'],
  );
  Map<String, dynamic> toJson() => {
    'release_episode_id': releaseEpisodeId,
    'time': time,
    'is_watched': isWatched,
  };
}
