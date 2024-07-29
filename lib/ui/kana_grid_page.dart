import 'package:flutter/material.dart';

class KanaGridPage extends StatelessWidget {
  final Map<String, String> kanasMap;
  final String script;

  const KanaGridPage({super.key, required this.script, required this.kanasMap});

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
          return Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    kanas[index].key,
                    style: const TextStyle(fontSize: 32),
                  ),
                  Text(
                    kanas[index].value,
                    style: const TextStyle(fontSize: 16, color: Colors.purple),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
