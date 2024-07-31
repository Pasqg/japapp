import 'dart:math';
import 'package:japapp/core/kana.dart';

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

  (K, V) getN(int n) {
    final random = Random();
    final entries = _data.entries;
    final entry = entries.elementAt(random.nextInt(min(n, entries.length)));
    return (entry.key, entry.value);
  }

  (K, V) get() {
    return getN(_data.entries.length);
  }

  Map<K, V> getAll() {
    return _data;
  }
}
