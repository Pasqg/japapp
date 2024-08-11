import 'package:flutter/material.dart';
import 'package:japapp/core/kana.dart';
import 'package:japapp/core/kanjis.dart';
import 'package:japapp/core/practice_type.dart';
import 'package:japapp/core/rand_data_provider.dart';
import 'package:japapp/ui/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  const PracticeSetProvider<String, (String, String)> practiceSetProvider =
      PracticeSetProvider(map: {
    PracticeType.Hiragana: RandData(data: HIRAGANA_MAP),
    PracticeType.Katakana: RandData(data: KATAKANA_MAP),
    PracticeType.Kanji: RandData(data: SINGLE_KANJI_WORDS),
    PracticeType.Words2: RandData(data: DOUBLE_KANJI_WORDS),
    PracticeType.Words3: RandData(data: TRIPLE_KANJI_WORDS),
    PracticeType.Verbs: RandData(data: VERBS),
    PracticeType.Sentences: RandData(data: EASY_SENTENCES),
  });

  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();
  runApp(MyApp(
      sharedPrefs: sharedPrefs, practiceSetProvider: practiceSetProvider));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPrefs;
  final PracticeSetProvider<String, (String, String)> practiceSetProvider;

  const MyApp(
      {super.key,
      required this.sharedPrefs,
      required this.practiceSetProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JapApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainPage(
        sharedPrefs: sharedPrefs,
        practiceSetProvider: practiceSetProvider,
      ),
    );
  }
}
