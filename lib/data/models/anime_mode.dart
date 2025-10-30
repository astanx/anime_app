enum AnimeMode { dub, sub }

extension AnimeModeExt on AnimeMode {
  String get name => toString().split('.').last;

  static AnimeMode fromString(String value) {
    switch (value) {
      case 'sub':
        return AnimeMode.sub;
      case 'dub':
        return AnimeMode.dub;
      default:
        throw ArgumentError('Invalid mode: $value');
    }
  }
}
