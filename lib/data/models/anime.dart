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
    this.notification,
    this.externalPlayer,
    required this.members,
    required this.torrents,
    this.sponsor,
    required this.episodes,
  });

  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
    release: AnimeRelease.fromJson(json),
    notification: json['notification'] as String?,
    externalPlayer: json['external_player'] as String?,
    members:
        (json['members'] as List<dynamic>?)
            ?.map((e) => Member.fromJson(e))
            .toList() ??
        [],
    torrents:
        (json['torrents'] as List<dynamic>?)
            ?.map((e) => Torrent.fromJson(e))
            .toList() ??
        [],
    sponsor: json['sponsor'] != null ? Sponsor.fromJson(json['sponsor']) : null,
    episodes:
        (json['episodes'] as List<dynamic>?)
            ?.map((e) => LatestEpisode.fromJson(e))
            .toList() ??
        [],
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
    id: json['id'] as String? ?? '',
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
    nickname: json['nickname'] as String? ?? '',
  );
}

class MemberUser {
  final int id;
  final String nickname;
  final Avatar avatar;

  MemberUser({required this.id, required this.nickname, required this.avatar});

  factory MemberUser.fromJson(Map<String, dynamic> json) => MemberUser(
    id: json['id'] as int? ?? 0,
    nickname: json['nickname'] as String? ?? '',
    avatar:
        json['avatar'] != null
            ? Avatar.fromJson(json['avatar'])
            : Avatar(
              preview: '',
              thumbnail: '',
              optimized: AvatarOptimized(preview: '', thumbnail: ''),
            ),
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
    preview: json['preview'] as String? ?? '',
    thumbnail: json['thumbnail'] as String? ?? '',
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
      AvatarOptimized(
        preview: json['preview'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
      );
}

class MemberRole {
  final String value;
  final String description;

  MemberRole({required this.value, required this.description});

  factory MemberRole.fromJson(Map<String, dynamic> json) => MemberRole(
    value: json['value'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
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
    id: json['id'] as int? ?? 0,
    hash: json['hash'] as String? ?? '',
    size: json['size'] as int? ?? 0,
    type: TorrentType.fromJson(json['type'] ?? {}),
    label: json['label'] as String? ?? '',
    magnet: json['magnet'] as String? ?? '',
    filename: json['filename'] as String? ?? '',
    seeders: json['seeders'] as int? ?? 0,
    quality: TorrentQuality.fromJson(json['quality'] ?? {}),
    codec: TorrentCodec.fromJson(json['codec'] ?? {}),
    color: TorrentColor.fromJson(json['color'] ?? {}),
    bitrate: json['bitrate'] as int? ?? 0,
    leechers: json['leechers'] as int? ?? 0,
    sortOrder: json['sort_order'] as int? ?? 0,
    updatedAt:
        json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
            : DateTime.now(),
    description: json['description'] as String? ?? '',
    completedTimes: json['completed_times'] as int? ?? 0,
  );
}

class TorrentType {
  final String value;
  final String description;

  TorrentType({required this.value, required this.description});

  factory TorrentType.fromJson(Map<String, dynamic> json) => TorrentType(
    value: json['value'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

class TorrentQuality {
  final String value;
  final String description;

  TorrentQuality({required this.value, required this.description});

  factory TorrentQuality.fromJson(Map<String, dynamic> json) => TorrentQuality(
    value: json['value'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

class TorrentCodec {
  final String value;
  final String description;

  TorrentCodec({required this.value, required this.description});

  factory TorrentCodec.fromJson(Map<String, dynamic> json) => TorrentCodec(
    value: json['value'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

class TorrentColor {
  final String value;
  final String description;

  TorrentColor({required this.value, required this.description});

  factory TorrentColor.fromJson(Map<String, dynamic> json) => TorrentColor(
    value: json['value'] as String? ?? '',
    description: json['description'] as String? ?? '',
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
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    urlTitle: json['url_title'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );
}
