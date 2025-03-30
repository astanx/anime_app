import 'dart:convert';

class Anime {
  final int id;
  final String code;
  final AnimeNames names;
  final List<Franchise> franchises;
  final String announce;
  final Status status;
  final Posters posters;
  final int updated;
  final int lastChange;
  final AnimeType type;
  final List<String> genres;
  final Team team;
  final Season season;
  final String description;
  final int inFavorites;
  final bool blocked;
  final Player player;
  final Torrents torrents;

  Anime({
    required this.id,
    required this.code,
    required this.names,
    required this.franchises,
    required this.announce,
    required this.status,
    required this.posters,
    required this.updated,
    required this.lastChange,
    required this.type,
    required this.genres,
    required this.team,
    required this.season,
    required this.description,
    required this.inFavorites,
    required this.blocked,
    required this.player,
    required this.torrents,
  });

  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
    id: json['id'],
    code: json['code'],
    names: AnimeNames.fromJson(json['names']),
    franchises:
        (json['franchises'] as List).map((e) => Franchise.fromJson(e)).toList(),
    announce: json['announce'],
    status: Status.fromJson(json['status']),
    posters: Posters.fromJson(json['posters']),
    updated: json['updated'],
    lastChange: json['last_change'],
    type: AnimeType.fromJson(json['type']),
    genres: List<String>.from(json['genres']),
    team: Team.fromJson(json['team']),
    season: Season.fromJson(json['season']),
    description: json['description'],
    inFavorites: json['in_favorites'],
    blocked: json['blocked']['blocked'],
    player: Player.fromJson(json['player']),
    torrents: Torrents.fromJson(json['torrents']),
  );
}

class AnimeNames {
  final String ru;
  final String en;

  AnimeNames({required this.ru, required this.en});

  factory AnimeNames.fromJson(Map<String, dynamic> json) =>
      AnimeNames(ru: json['ru'], en: json['en']);
}

class Franchise {
  final String id;
  final String name;

  Franchise({required this.id, required this.name});

  factory Franchise.fromJson(Map<String, dynamic> json) =>
      Franchise(id: json['franchise']['id'], name: json['franchise']['name']);
}

class Status {
  final String string;
  final int code;

  Status({required this.string, required this.code});

  factory Status.fromJson(Map<String, dynamic> json) =>
      Status(string: json['string'], code: json['code']);
}

class Posters {
  final String small;
  final String medium;
  final String original;

  Posters({required this.small, required this.medium, required this.original});

  factory Posters.fromJson(Map<String, dynamic> json) => Posters(
    small: json['small']['url'],
    medium: json['medium']['url'],
    original: json['original']['url'],
  );
}

class AnimeType {
  final String fullString;
  final int length;

  AnimeType({required this.fullString, required this.length});

  factory AnimeType.fromJson(Map<String, dynamic> json) =>
      AnimeType(fullString: json['full_string'], length: json['length']);
}

class Team {
  final List<String> voice;
  final List<String> translator;
  final List<String> editing;
  final List<String> decor;
  final List<String> timing;

  Team({
    required this.voice,
    required this.translator,
    required this.editing,
    required this.decor,
    required this.timing,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    voice: List<String>.from(json['voice']),
    translator: List<String>.from(json['translator']),
    editing: List<String>.from(json['editing']),
    decor: List<String>.from(json['decor']),
    timing: List<String>.from(json['timing']),
  );
}

class Season {
  final String string;
  final int year;

  Season({required this.string, required this.year});

  factory Season.fromJson(Map<String, dynamic> json) =>
      Season(string: json['string'], year: json['year']);
}

class Player {
  final String host;
  final Episodes episodes;
  final Map<String, Episode> list;

  Player({required this.host, required this.episodes, required this.list});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    host: json['host'],
    episodes: Episodes.fromJson(json['episodes']),
    list: (json['list'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, Episode.fromJson(value)),
    ),
  );
}

class Episodes {
  final int first;
  final int last;
  final String string;

  Episodes({required this.first, required this.last, required this.string});

  factory Episodes.fromJson(Map<String, dynamic> json) => Episodes(
    first: json['first'],
    last: json['last'],
    string: json['string'],
  );
}

class Episode {
  final int episode;
  final String uuid;

  Episode({required this.episode, required this.uuid});

  factory Episode.fromJson(Map<String, dynamic> json) =>
      Episode(episode: json['episode'], uuid: json['uuid']);
}

class Torrents {
  final Episodes episodes;
  final List<Torrent> list;

  Torrents({required this.episodes, required this.list});

  factory Torrents.fromJson(Map<String, dynamic> json) => Torrents(
    episodes: Episodes.fromJson(json['episodes']),
    list: (json['list'] as List).map((e) => Torrent.fromJson(e)).toList(),
  );
}

class Torrent {
  final int torrentId;
  final String quality;
  final int seeders;
  final int downloads;
  final String sizeString;
  final String magnet;

  Torrent({
    required this.torrentId,
    required this.quality,
    required this.seeders,
    required this.downloads,
    required this.sizeString,
    required this.magnet,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) => Torrent(
    torrentId: json['torrent_id'],
    quality: json['quality']['string'],
    seeders: json['seeders'],
    downloads: json['downloads'],
    sizeString: json['size_string'],
    magnet: json['magnet'],
  );
}

Anime parseAnime(String jsonStr) {
  final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
  return Anime.fromJson(jsonData);
}
