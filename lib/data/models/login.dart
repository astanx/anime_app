class Login {
  final String token;
  final String error;

  Login({required this.token, required this.error});

  factory Login.fromJson(Map<String, dynamic> json) =>
      Login(token: json['token'] ?? '', error: json['error'] ?? '');
}
