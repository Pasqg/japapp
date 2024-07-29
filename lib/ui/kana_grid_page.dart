import 'package:flutter/material.dart';
import 'package:japapp/core/kana_stats.dart';

class KanaGridPage extends StatelessWidget {
  final Map<String, String> kanasMap;
  final String script;
  final PracticeStats<String> stats;

  const KanaGridPage(
      {super.key,
      required this.script,
      required this.kanasMap,
      required this.stats});

  Color _getColorForPercentage(int percentage) {
    if (percentage < 40) {
      return Color.lerp(Colors.red, Colors.orange, percentage / 50)!;
    } else if (percentage < 60) {
      return Color.lerp(Colors.orange, Colors.yellow, (percentage - 50) / 10)!;
    } else if (percentage < 99) {
      return Color.lerp(Colors.yellow, Colors.green, (percentage - 60) / 39)!;
    } else {
      return Colors.green;
    }
  }

  (int percentage, int correct, int total) _percentageForKana(String kana) {
    var (correct, total) = stats.getStats(kana);
    var percentage = total > 0 ? (correct / total * 100).round() : 0;
    return (percentage, correct, total);
  }

  void _showKanaDialog(
      BuildContext context, String kana, String transliteration) {
    var (percentage, correct, total) = _percentageForKana(kana);
    var color = _getColorForPercentage(percentage);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: color,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage% (correct: $correct/total: $total)',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                kana,
                style: const TextStyle(fontSize: 100),
              ),
              const SizedBox(height: 10),
              Text(
                transliteration,
                style: const TextStyle(fontSize: 24, color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kanas = kanasMap.entries.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('$script Grid'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        padding: const EdgeInsets.all(8.0),
        itemCount: kanas.length,
        itemBuilder: (context, index) {
          var entry = kanas[index];
          var kana = entry.key;
          var transliteration = entry.value;
          var (percentage, _, _) = _percentageForKana(kana);
          return GestureDetector(
            onTap: () {
              _showKanaDialog(context, kana, transliteration);
            },
            child: Card(
              color: _getColorForPercentage(percentage).withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kana,
                      style: const TextStyle(fontSize: 32),
                    ),
                    Text(
                      transliteration,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.purple),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
