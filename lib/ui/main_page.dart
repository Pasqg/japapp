import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:japapp/core/practice_stats.dart';
import 'package:japapp/core/practice_type.dart';

import 'package:japapp/core/rand_data_provider.dart';
import 'package:japapp/ui/kana_grid_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final SharedPreferences sharedPrefs;
  final PracticeSetProvider<String, (String, String)> practiceSetProvider;

  const MainPage(
      {super.key,
      required this.sharedPrefs,
      required this.practiceSetProvider});

  @override
  MainPageState createState() => MainPageState(
      sharedPrefs: sharedPrefs, practiceSetProvider: practiceSetProvider);
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _transliterationController =
      TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  final PracticeStats _practiceStats;
  final PracticeSetProvider<String, (String, String)> _practiceSetProvider;

  late TabController _tabController;

  PracticeType _selectedScript = PracticeType.Hiragana;
  (String japanese, (String transliteration, String translation)) _currentKana =
      ('', ('', ''));
  bool _isNextHiraganaDisabled = true;
  bool _transliterate = Random().nextBool();

  MainPageState(
      {required SharedPreferences sharedPrefs,
      required PracticeSetProvider<String, (String, String)>
          practiceSetProvider})
      : _practiceStats = PracticeStats(sharedPrefs: sharedPrefs),
        _practiceSetProvider = practiceSetProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _transliterationController.addListener(_enableDisableNextButton);
    _nextKana();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _transliterationController.dispose();
    super.dispose();
  }

  RandData<String, (String, String)> _kanaProvider() {
    return _practiceSetProvider.getSet(_selectedScript);
  }

  void _nextKana() {
    setState(() {
      final data = _kanaProvider().getAll();
      final keys = data.keys;
      _currentKana = _kanaProvider().getN(_practiceStats.learnedCount(keys));
      _transliterate = Random().nextBool();
    });
  }

  (String, String) _hintText(int threshold) {
    String hintText = "";
    if (_practiceStats.getStats(_currentKana.$1).percentage() <= threshold) {
      var (String transliteration, String translation) = _currentKana.$2;
      hintText = transliteration;
      if (transliteration != translation) {
        return (transliteration, translation);
      }
      return (transliteration, "");
    }
    return ("", "");
  }

  void _enableDisableNextButton() {
    setState(() {
      _isNextHiraganaDisabled = _transliterationController.text.isEmpty;
    });
  }

  Future<void> _validateTransliteration() async {
    var userInput = _transliterationController.text.trim().split(",");
    _transliterationController.clear();
    var userTransliteration = userInput[0].trim().toLowerCase();
    var userTranslation =
        userInput.length > 1 ? userInput[1].trim().toLowerCase() : "";

    var (String transliteration, String translation) = _currentKana.$2;
    var translations =
        translation.split(", ").map((s) => s.trim().toLowerCase()).toSet();

    var isCorrect = false;
    var expected = transliteration;
    if (transliteration == translation) {
      isCorrect = userTransliteration == transliteration;
    } else {
      isCorrect = userTransliteration == transliteration &&
          translations.contains(userTranslation);
      expected = "$expected - $translation";
    }

    _recordStats(isCorrect, expected, userTransliteration);
    _enableDisableNextButton();
    _nextKana();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _recordStats(
      bool isCorrect, String expected, String? confusedWithTranslit) {
    if (isCorrect) {
      _practiceStats.record(_currentKana.$1, true, null);
      _showCustomSnackBar('Correct!', Colors.green);
    } else {
      var confusedWith;
      if (confusedWithTranslit != null) {
        confusedWith = _kanaProvider().get(confusedWithTranslit);
      }
      _practiceStats.record(_currentKana.$1, false, confusedWith);
      _showCustomSnackBar('Incorrect! It was "$expected"', Colors.red);
    }
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
            script: _selectedScript.name,
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
            Tab(text: "Script"),
            Tab(text: 'Words'),
            Tab(text: 'Talk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _transliterate ? _transliterationView() : _selectionView(),
          const Center(child: Text('Coming soon...')),
          const Center(child: Text('Coming soon...')),
        ],
      ),
    );
  }

  Widget _commonOptions() {
    return Stack(children: [
      Positioned(
        top: 16,
        left: 16,
        child: DropdownButton<PracticeType>(
          value: _selectedScript,
          items: PracticeType.values.map((PracticeType value) {
            return DropdownMenuItem<PracticeType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          onChanged: (PracticeType? newValue) {
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
      )
    ]);
  }

  Widget _selectionView() {
    final currentKana = _currentKana.$1;
    final allKanas = _kanaProvider().getAll().keys;
    final learnedCount = _practiceStats.learnedCount(allKanas);
    var randomKanasSet = {currentKana};
    final confusedSet =
        _practiceStats.getStats(currentKana).confusedSet.keys.toList();
    confusedSet.shuffle();
    for (int i = 0; i < min(3, confusedSet.length); i++) {
      randomKanasSet.add(confusedSet[i]);
    }
    int tentatives = 0;
    int expectedLength = min(6, allKanas.length);
    final random = Random();
    while (randomKanasSet.length < expectedLength && tentatives < 64) {
      randomKanasSet.add(allKanas.elementAt(random.nextInt(allKanas.length)));
      tentatives += 1;
    }
    final randomKanas = randomKanasSet.map((a) => a).toList();
    randomKanas.shuffle();
    final (String transliteration, String translation) = _hintText(100);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        _commonOptions(),
        Positioned(
          top: 100,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9),
            child: Text(
              transliteration,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        Positioned(
          top: 210,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9),
            child: Text(
              translation,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 300.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns
            ),
            itemCount: randomKanas.length,
            itemBuilder: (context, index) {
              final kana = randomKanas[index];
              return GestureDetector(
                onTap: () {
                  if (currentKana == kana) {
                    _practiceStats.record(currentKana, true, null);
                    _showCustomSnackBar('Correct!', Colors.green);
                  } else {
                    _practiceStats.record(currentKana, false, kana);
                    _practiceStats.record(kana, false, currentKana);
                    _showCustomSnackBar(
                        'Incorrect! It was "$currentKana"', Colors.red);
                  }
                  _nextKana();
                },
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          kana,
                          style: TextStyle(fontSize: kana.length >= 2 ? max(24, 120 / kana.length) : 72),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _transliterationView() {
    final hint = _hintText(50);
    return Stack(
      children: [
        _commonOptions(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentKana.$1,
                  style: TextStyle(
                      fontSize: _currentKana.$1.length > 4 ? 48 : 100,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  hint.$1,
                  style: TextStyle(fontSize: hint.$1.length > 4 ? 24 : 32),
                ),
                Text(
                  hint.$2,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _transliterationController,
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
