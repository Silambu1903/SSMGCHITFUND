import 'unicode_to_bamini_data.dart';

/// Converts Unicode Tamil text to Bamini font encoding for legacy TTF rendering.
class UnicodeToBamini {
  UnicodeToBamini._();

  static final _sortedPairs = List<MapEntry<String, String>>.from(
    baminiUnicodePairs,
  )..sort((a, b) => b.key.length.compareTo(a.key.length));

  /// Returns [text] with Tamil Unicode syllables replaced by Bamini keystrokes.
  /// ASCII digits, English, and punctuation are left unchanged.
  static String convert(String text) {
    if (text.isEmpty) return text;

    var out = text;
    for (final pair in _sortedPairs) {
      if (out.contains(pair.key)) {
        out = out.replaceAll(pair.key, pair.value);
      }
    }
    return out;
  }

  /// Converts only if the string contains Tamil Unicode characters.
  static String convertIfTamil(String text) {
    if (!_containsTamil(text)) return text;
    return convert(text);
  }

  static bool _containsTamil(String text) {
    for (final codeUnit in text.runes) {
      if (codeUnit >= 0x0B80 && codeUnit <= 0x0BFF) return true;
    }
    return false;
  }
}
