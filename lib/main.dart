import 'package:flutter/material.dart';
import 'package:japapp/ui/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
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
