import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const EVICT_THRESHOLD = 6;

class Stat {
  final int correct;
  final int total;
  final Map<String, int> confusedSet;

  Stat(this.correct, this.total, this.confusedSet);

  static Stat empty() {
    return Stat(0, 0, {});
  }

  int percentage() {
    return total > 0 ? (correct / total * 100).round() : 0;
  }

  String toJson() {
    return jsonEncode({
      'correct': correct,
      'total': total,
      'confusedSet': confusedSet,
    });
  }

  factory Stat.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    final jsonConfusedSet = json['confusedSet'];
    Map<String, int> confusedSet = {};
    if (jsonConfusedSet != null) {
      confusedSet = Map<String, int>.from(jsonConfusedSet.cast<String, int>());
    }
    return Stat(
      json['correct'],
      json['total'],
      confusedSet,
    );
  }
}

class PracticeStats {
  final SharedPreferences sharedPrefs;

  PracticeStats({required this.sharedPrefs});

  Future<void> record(
      String datum, bool isCorrect, String? confusedWith) async {
    var stat = getStats(datum);
    updateConfusedSets(stat.confusedSet, confusedWith);
    final newStat = Stat(
      isCorrect ? stat.correct + 1 : stat.correct,
      stat.total + 1,
      stat.confusedSet,
    );
    _updateStat(datum, newStat);
    if (confusedWith != null) {
      _updateStat(confusedWith, newStat);
    }
  }

  Stat getStats(String datum) {
    final json = sharedPrefs.getString(datum);
    if (json != null) {
      return Stat.fromJson(json);
    } else {
      return Stat.empty();
    }
  }

  int learnedCount(Iterable<String> keys) {
    var totalStat = Stat.empty();
    var count = 1;
    for (String k in keys) {
      var stat = getStats(k);
      totalStat = Stat(
          totalStat.correct + stat.correct, totalStat.total + stat.total, {});
      count += 1;
      if (totalStat.percentage() < 80 || totalStat.total / count <= 3) {
        break;
      }
    }
    return count;
  }

  void _updateStat(String key, Stat stat) async {
    await sharedPrefs.setString(key, stat.toJson());
    await sharedPrefs.reload();
  }

  static void updateConfusedSets(currentSet, String? confusedWith) {
    if (confusedWith != null) {
      if (currentSet.containsKey(confusedWith)) {
        currentSet[confusedWith] += 1;
      } else {
        if (currentSet.length >= EVICT_THRESHOLD) {
          final entry =
              currentSet.entries.reduce((a, b) => a.value < b.value ? a : b);
          currentSet.remove(entry.key);
        }
        currentSet[confusedWith] = 1;
      }
    }
  }
}
