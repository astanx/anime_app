enum Mode { anilibria, consumet }

extension ModeExt on Mode {
  String get name => toString().split('.').last;

  static Mode fromString(String value) {
    switch (value) {
      case 'anilibria':
        return Mode.anilibria;
      case 'consumet':
        return Mode.consumet;
      default:
        throw ArgumentError('Invalid mode: $value');
    }
  }
}
