import 'package:flutter/material.dart';
import 'package:japapp/core/kana.dart';
import 'package:japapp/core/kanjis.dart';
import 'package:japapp/core/rand_data_provider.dart';
import 'package:japapp/ui/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {

  const RandDataProvider<String, (String, String)> hiraganaProvider =
      RandDataProvider(data: HIRAGANA_MAP);
  const RandDataProvider<String, (String, String)> katakanaProvider =
      RandDataProvider(data: KATAKANA_MAP);
  const RandDataProvider<String, (String, String)> kanjiProvider =
      RandDataProvider(data: SINGLE_KANJI_WORDS);

  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPrefs: sharedPrefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPrefs;

  const MyApp({super.key, required this.sharedPrefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JapApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainPage(sharedPrefs: sharedPrefs),
    );
  }
}
