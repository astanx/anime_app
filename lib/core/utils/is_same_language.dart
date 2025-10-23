bool isSameSubtitleLanguage(String code, String name) {
  final languageMap = {
    'en': 'english',
    'ru': 'russian',
    'es': 'spanish',
    'fr': 'french',
    'de': 'german',
    'ja': 'japanese',
    'zh-cn': 'chinese',
    'ko': 'korean',
    'it': 'italian',
    'pt': 'portuguese',
  };

  final normalizedCode = code.toLowerCase();
  final normalizedName = name.toLowerCase().trim();

  if (languageMap[normalizedCode] == normalizedName) return true;

  if (normalizedCode == normalizedName) return true;

  final mappedName = languageMap[normalizedCode];
  if (mappedName != null && normalizedName.contains(mappedName)) return true;

  return false;
}
