class PracticeStats<T> {
  late final Map<T, (int correct, int total)> _stats = {};

  void record(T datum, bool isCorrect) {
    if (!_stats.containsKey(datum)) {
      _stats[datum] = (0, 0);
    }
    var (correct, total) = _stats[datum]!;
    _stats[datum] = (isCorrect ? correct + 1 : correct, total + 1);
  }

  (int correct, int total) getStats(T datum) {
    return _stats.containsKey(datum) ? _stats[datum]! : (0, 0);
  }
}
