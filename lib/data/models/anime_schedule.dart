import 'package:anime_app/data/models/anime.dart';

class Schedule {
  final int day;
  final List<Anime> list;

  Schedule({required this.day, required this.list});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      day: json['day'],
      list:
          (json['list'] as List<dynamic>)
              .map((anime) => Anime.fromJson(anime))
              .toList(),
    );
  }
}
