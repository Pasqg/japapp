import 'dart:math';
import 'package:japapp/core/kana.dart';
import 'package:japapp/core/kanjis.dart';

// todo: should keep a frequency map and give higher probability of next draw to lower frequencies
class RandDataProvider<K, V> {
  final Map<K, V> _data;

  const RandDataProvider({required Map<K, V> data}) : _data = data;

  static const RandDataProvider<String, (String, String)> HIRAGANA =
      RandDataProvider(data: HIRAGANA_MAP);
  static const RandDataProvider<String, (String, String)> KATAKANA =
      RandDataProvider(data: KATAKANA_MAP);
  static const RandDataProvider<String, (String, String)> WORDS_3000 =
      RandDataProvider(data: WORDS_3000_MAP);
  static const RandDataProvider<String, (String, String)> WORDS_50 =
      RandDataProvider(data: WORDS_50_MAP);
  static const RandDataProvider<String, (String, String)> SINGLE_KANJI =
      RandDataProvider(data: SINGLE_KANJI_WORDS);

  (K, V) getN(int n) {
    final random = Random();
    final entries = _data.entries;
    final entry = entries.elementAt(random.nextInt(min(n, entries.length)));
    return (entry.key, entry.value);
  }

  V? get(K key) {
    return _data[key];
  }

  Map<K, V> getAll() {
    return _data;
  }
}
