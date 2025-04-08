class AuthUrl {
  final String state;
  final String url;

  AuthUrl({required this.url, required this.state});

  factory AuthUrl.fromJson(Map<String, dynamic> json) =>
      AuthUrl(state: json['state'] ?? '', url: json['url'] ?? '');
}
