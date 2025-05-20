class KodikResult {
  final String id;
  final String type;
  final String link;
  final String title;
  final String titleOrig;
  final String otherTitle;
  final int year;
  final String? shikimoriId;
  final List<String>? screenshots;

  KodikResult({
    required this.id,
    required this.type,
    required this.link,
    required this.title,
    required this.titleOrig,
    required this.otherTitle,
    required this.year,
    this.shikimoriId,
    this.screenshots,
  });

  factory KodikResult.fromJson(Map<String, dynamic> json) => KodikResult(
    id: json['id'] ?? '',
    type: json['type'] ?? '',
    link: json['link'] ?? '',
    title: json['title'] ?? '',
    titleOrig: json['title_orig'] ?? '',
    otherTitle: json['other_title'] ?? '',
    year: json['year'] ?? 0,
    shikimoriId: json['shikimori_id']?.toString(),
    screenshots:
        (json['screenshots'] as List?)?.map((s) => s.toString()).toList(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'link': link,
    'title': title,
    'title_orig': titleOrig,
    'other_title': otherTitle,
    'year': year,
    'shikimori_id': shikimoriId,
    'screenshots': screenshots,
  };
}
