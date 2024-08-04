import 'dart:math';
import 'package:japapp/core/practice_type.dart';

// todo: should keep a frequency map and give higher probability of next draw to lower frequencies
class RandData<K, V> {
  final Map<K, V> _data;

  const RandData({required Map<K, V> data}) : _data = data;

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

class PracticeSetProvider<K, V> {
  final Map<PracticeType, RandData<K, V>> _map;

  const PracticeSetProvider({required Map<PracticeType, RandData<K, V>> map})
      : _map = map;

  RandData<K, V> getSet(PracticeType type) {
    return _map[type] ?? const RandData(data: {});
  }
}
