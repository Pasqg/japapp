import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Stat {
  final int correct;
  final int total;

  Stat(this.correct, this.total);

  int percentage() {
    return total > 0 ? (correct / total * 100).round() : 0;
  }

  String toJson() {
    return jsonEncode({
      'correct': correct,
      'total': total,
    });
  }

  factory Stat.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return Stat(
      json['correct'],
      json['total'],
    );
  }
}

class PracticeStats {
  final SharedPreferences sharedPrefs;

  PracticeStats({required this.sharedPrefs});

  Future<void> record(String datum, bool isCorrect) async {
    final json = sharedPrefs.getString(datum);
    var stat = Stat(0, 0);
    if (json != null) {
      stat = Stat.fromJson(json);
    } else {
      stat = Stat(0, 0);
    }

    final newStat =
        Stat(isCorrect ? stat.correct + 1 : stat.correct, stat.total + 1);
    await sharedPrefs.setString(datum, newStat.toJson());
    await sharedPrefs.reload();
  }

  Stat getStats(String datum) {
    final json = sharedPrefs.getString(datum);
    if (json != null) {
      return Stat.fromJson(json);
    } else {
      return Stat(0, 0);
    }
  }
}
