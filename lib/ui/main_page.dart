import 'dart:async';

import 'package:flutter/material.dart';
import 'package:japapp/core/practice_stats.dart';

import 'package:japapp/core/rand_data_provider.dart';
import 'package:japapp/ui/kana_grid_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final SharedPreferences sharedPrefs;

  const MainPage({super.key, required this.sharedPrefs});

  @override
  MainPageState createState() => MainPageState(sharedPrefs: sharedPrefs);
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  final PracticeStats _practiceStats;

  late TabController _tabController;

  String _selectedScript = "Hiragana";
  (String japanese, (String transliteration, String translation)) _currentKana =
      ('', ('', ''));
  bool _isNextHiraganaDisabled = true;

  MainPageState({required SharedPreferences sharedPrefs}) : _practiceStats = PracticeStats(sharedPrefs: sharedPrefs);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _textEditingController.addListener(_enableDisableNextButton);
    _nextKana();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  RandDataProvider<String, (String, String)> _kanaProvider() {
    if (_selectedScript == 'Hiragana') {
      return RandDataProvider.HIRAGANA;
    } else if (_selectedScript == 'Katakana') {
      return RandDataProvider.KATAKANA;
    } else {
      return RandDataProvider.WORDS_3000;
    }
  }

  void _nextKana() {
    setState(() {
      final data = _kanaProvider().getAll();
      final keys = data.keys;

      var totalStat = Stat(0, 0);
      var count = 1;
      for (String k in keys) {
        var stat = _practiceStats.getStats(k);
        totalStat = Stat(totalStat.correct + stat.correct, totalStat.total + stat.total);
        count += 1;
        if (totalStat.percentage() < 80) {
          break;
        }
      }
      _currentKana = _kanaProvider().getN(count);
    });
  }

  void _enableDisableNextButton() {
    setState(() {
      _isNextHiraganaDisabled = _textEditingController.text.isEmpty;
    });
  }

  Future<void> _validateTransliteration() async {
    String transliteration = _textEditingController.text.trim();
    _textEditingController.clear();
    String expected = _currentKana.$2.$1;
    String translation = _currentKana.$2.$2;
    if (translation != expected) {
      expected = "$expected - $translation";
    }
    if (expected == transliteration) {
      _practiceStats.record(_currentKana.$1, true);
      _showCustomSnackBar('Correct!', Colors.green);
    } else {
      _practiceStats.record(_currentKana.$1, false);
      _showCustomSnackBar('Incorrect! It was "$expected"', Colors.red);
    }
    _enableDisableNextButton();
    _nextKana();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _showCustomSnackBar(String message, Color color) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    Timer(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }

  void _openKanaGrid() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KanaGridPage(
            script: _selectedScript,
            kanasMap: _kanaProvider().getAll(),
            stats: _practiceStats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hiragana'),
            Tab(text: 'Words'),
            Tab(text: 'Talk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHiraganaView(),
          const Center(child: Text('Coming soon...')),
          const Center(child: Text('Coming soon...')),
        ],
      ),
    );
  }

  Widget _buildHiraganaView() {
    return Stack(
      children: [
        Positioned(
          top: 16,
          left: 16,
          child: DropdownButton<String>(
            value: _selectedScript,
            items:
                <String>['Hiragana', 'Katakana', 'Words'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedScript = newValue!;
                _nextKana();
              });
            },
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: _openKanaGrid,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentKana.$1,
                  style: const TextStyle(
                      fontSize: 100, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Transliteration',
                  ),
                  focusNode: _focusNode,
                  onSubmitted: (value) async {
                    if (!_isNextHiraganaDisabled) {
                      await _validateTransliteration();
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      _isNextHiraganaDisabled ? null : _validateTransliteration,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
