import 'package:flutter/material.dart';
import 'package:japapp/ui/main_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JapApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainPage(),
    );
  }
}
