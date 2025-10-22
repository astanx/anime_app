import 'package:anime_app/data/models/episode.dart';

class Anime {
  final String id;
  final String title;
  final String poster;
  final String description;
  final List<String> genres;
  final String status;
  final int? year;
  final String type;
  final int totalEpisodes;
  final List<PreviewEpisode> previewEpisodes;
  List<Episode> episodes = [];

  Anime({
    required this.id,
    required this.title,
    required this.poster,
    required this.description,
    required this.genres,
    required this.status,
    required this.type,
    required this.totalEpisodes,
    required this.previewEpisodes,
    required this.episodes,
    this.year,
  });

  bool get isMovie => type.toLowerCase() == 'movie';

  factory Anime.fromJsonPreview(Map<String, dynamic> json) {
    json = json['result'];
    return Anime(
      id: json['id'],
      title: json['title'],
      poster: json['image'],
      description: json['description'],
      genres:
          (json['genres'] as List<dynamic>).map((g) => g.toString()).toList(),
      status: json['status'],
      year: json['year'] > 0 ? json['year'] : null,
      type: json['type'] as String,
      totalEpisodes: json['total_episodes'],
      previewEpisodes:
          (json['episodes'] as List<dynamic>)
              .map((e) => PreviewEpisode.fromJson(e))
              .toList(),
      episodes: [],
    );
  }
  static List<Anime> fromListJsonPreview(Map<String, dynamic> json) {
    return (json['results'] as List<dynamic>)
        .map((e) => Anime.fromJsonPreview(e as Map<String, dynamic>))
        .toList();
  }
}
