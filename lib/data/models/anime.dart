import 'package:anime_app/data/models/anime_release.dart';

class Anime {
  final AnimeRelease release;
  final String? notification;
  final String? externalPlayer;
  final List<Member> members;
  final List<Torrent> torrents;
  final Sponsor? sponsor;
  final List<LatestEpisode> episodes;

  Anime({
    required this.release,
    required this.notification,
    required this.externalPlayer,
    required this.members,
    required this.torrents,
    required this.sponsor,
    required this.episodes,
  });

  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
    release: AnimeRelease.fromJson(json),
    notification: json['notification'],
    externalPlayer: json['external_player'],
    members:
        (json['members'] as List<dynamic>? ?? [])
            .map((e) => Member.fromJson(e))
            .toList(),
    torrents:
        (json['torrents'] as List<dynamic>? ?? [])
            .map((e) => Torrent.fromJson(e))
            .toList(),
    sponsor: json['sponsor'] != null ? Sponsor.fromJson(json['sponsor']) : null,
    episodes:
        (json['episodes'] as List<dynamic>? ?? [])
            .map((e) => LatestEpisode.fromJson(e))
            .toList(),
  );
}

class Member {
  final String id;
  final MemberUser user;
  final MemberRole role;
  final String nickname;

  Member({
    required this.id,
    required this.user,
    required this.role,
    required this.nickname,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'] ?? '',
    user:
        json['user'] != null
            ? MemberUser.fromJson(json['user'])
            : MemberUser(
              id: 0,
              nickname: '',
              avatar: Avatar(
                preview: '',
                thumbnail: '',
                optimized: AvatarOptimized(preview: '', thumbnail: ''),
              ),
            ),
    role:
        json['role'] != null
            ? MemberRole.fromJson(json['role'])
            : MemberRole(value: '', description: ''),
    nickname: json['nickname'] ?? '',
  );
}

class MemberUser {
  final int id;
  final String nickname;
  final Avatar avatar;

  MemberUser({required this.id, required this.nickname, required this.avatar});

  factory MemberUser.fromJson(Map<String, dynamic> json) => MemberUser(
    id: json['id'],
    nickname: json['nickname'],
    avatar: Avatar.fromJson(json['avatar']),
  );
}

class Avatar {
  final String preview;
  final String thumbnail;
  final AvatarOptimized optimized;

  Avatar({
    required this.preview,
    required this.thumbnail,
    required this.optimized,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
    preview: json['preview'] ?? '',
    thumbnail: json['thumbnail'] ?? '',
    optimized:
        json['optimized'] != null
            ? AvatarOptimized.fromJson(json['optimized'])
            : AvatarOptimized(preview: '', thumbnail: ''),
  );
}

class AvatarOptimized {
  final String preview;
  final String thumbnail;

  AvatarOptimized({required this.preview, required this.thumbnail});

  factory AvatarOptimized.fromJson(Map<String, dynamic> json) =>
      AvatarOptimized(preview: json['preview'], thumbnail: json['thumbnail']);
}

class MemberRole {
  final String value;
  final String description;

  MemberRole({required this.value, required this.description});

  factory MemberRole.fromJson(Map<String, dynamic> json) =>
      MemberRole(value: json['value'], description: json['description']);
}

class Torrent {
  final int id;
  final String hash;
  final int size;
  final TorrentType type;
  final String label;
  final String magnet;
  final String filename;
  final int seeders;
  final TorrentQuality quality;
  final TorrentCodec codec;
  final TorrentColor color;
  final int bitrate;
  final int leechers;
  final int sortOrder;
  final DateTime updatedAt;
  final String description;
  final int completedTimes;

  Torrent({
    required this.id,
    required this.hash,
    required this.size,
    required this.type,
    required this.label,
    required this.magnet,
    required this.filename,
    required this.seeders,
    required this.quality,
    required this.codec,
    required this.color,
    required this.bitrate,
    required this.leechers,
    required this.sortOrder,
    required this.updatedAt,
    required this.description,
    required this.completedTimes,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) => Torrent(
    id: json['id'] ?? 0,
    hash: json['hash'] ?? '',
    size: json['size'] ?? 0,
    type: TorrentType.fromJson(json['type'] ?? {}),
    label: json['label'] ?? '',
    magnet: json['magnet'] ?? '',
    filename: json['filename'] ?? '',
    seeders: json['seeders'] ?? 0,
    quality: TorrentQuality.fromJson(json['quality'] ?? {}),
    codec: TorrentCodec.fromJson(json['codec'] ?? {}),
    color: TorrentColor.fromJson(json['color'] ?? {}),
    bitrate: json['bitrate'] ?? 0,
    leechers: json['leechers'] ?? 0,
    sortOrder: json['sort_order'] ?? 0,
    updatedAt:
        json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
            : DateTime.now(),
    description: json['description'] ?? '',
    completedTimes: json['completed_times'] ?? 0,
  );
}

class TorrentType {
  final String value;
  final String description;

  TorrentType({required this.value, required this.description});

  factory TorrentType.fromJson(Map<String, dynamic> json) =>
      TorrentType(value: json['value'], description: json['description']);
}

class TorrentQuality {
  final String value;
  final String description;

  TorrentQuality({required this.value, required this.description});

  factory TorrentQuality.fromJson(Map<String, dynamic> json) =>
      TorrentQuality(value: json['value'], description: json['description']);
}

class TorrentCodec {
  final String value;
  final String description;

  TorrentCodec({required this.value, required this.description});

  factory TorrentCodec.fromJson(Map<String, dynamic> json) =>
      TorrentCodec(value: json['value'], description: json['description']);
}

class TorrentColor {
  final String value;
  final String description;

  TorrentColor({required this.value, required this.description});

  factory TorrentColor.fromJson(Map<String, dynamic> json) => TorrentColor(
    value: json['value'] ?? '',
    description: json['description'] ?? '',
  );
}

class Sponsor {
  final String id;
  final String title;
  final String description;
  final String urlTitle;
  final String url;

  Sponsor({
    required this.id,
    required this.title,
    required this.description,
    required this.urlTitle,
    required this.url,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) => Sponsor(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    urlTitle: json['url_title'],
    url: json['url'],
  );
}
