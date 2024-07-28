import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  late TabController _tabController;

  String _currentHiragana = '';
  bool _isNextHiraganaDisabled = true;

  final Map<String, String> _hiraganaMap = {
    'あ': 'a',
    'い': 'i',
    'う': 'u',
    'え': 'e',
    'お': 'o',
    'か': 'ka',
    'き': 'ki',
    'く': 'ku',
    'け': 'ke',
    'こ': 'ko',
    'さ': 'sa',
    'し': 'shi',
    'す': 'su',
    'せ': 'se',
    'そ': 'so',
    'た': 'ta',
    'ち': 'chi',
    'つ': 'tsu',
    'て': 'te',
    'と': 'to',
    'な': 'na',
    'に': 'ni',
    'ぬ': 'nu',
    'ね': 'ne',
    'の': 'no',
    'は': 'ha',
    'ひ': 'hi',
    'ふ': 'fu',
    'へ': 'he',
    'ほ': 'ho',
    'ま': 'ma',
    'み': 'mi',
    'む': 'mu',
    'め': 'me',
    'も': 'mo',
    'や': 'ya',
    'ゆ': 'yu',
    'よ': 'yo',
    'ら': 'ra',
    'り': 'ri',
    'る': 'ru',
    'れ': 're',
    'ろ': 'ro',
    'わ': 'wa',
    'を': 'wo',
    'ん': 'n'
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _textEditingController.addListener(_enableDisableNextButton);
    _generateRandomHiragana();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void _generateRandomHiragana() {
    final random = Random();
    setState(() {
      _currentHiragana =
          _hiraganaMap.keys.elementAt(random.nextInt(_hiraganaMap.length));
    });
  }

  void _enableDisableNextButton() {
    setState(() {
      _isNextHiraganaDisabled = _textEditingController.text.isEmpty;
    });
  }

  void _validateTransliteration() {
    String transliteration = _textEditingController.text.trim();
    _textEditingController.clear();
    String? expected = _hiraganaMap[_currentHiragana];
    if (expected == transliteration) {
      _showCustomSnackBar('Correct!', Colors.green);
    } else {
      _showCustomSnackBar('Incorrect! It was "$expected"', Colors.red);
    }
    _enableDisableNextButton();
    _generateRandomHiragana();
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
    Timer(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentHiragana,
              style:
                  const TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Transliteration',
              ),
              focusNode: _focusNode,
              onSubmitted: (value) {
                if (!_isNextHiraganaDisabled) {
                  _validateTransliteration();
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
    );
  }
}
