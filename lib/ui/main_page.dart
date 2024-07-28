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

  String _selectedScript = "Hiragana";
  String _currentKana = '';
  bool _isNextHiraganaDisabled = true;

  static const Map<String, String> KATAKANA_MAP = {
    'ア': 'a',
    'イ': 'i',
    'ウ': 'u',
    'エ': 'e',
    'オ': 'o',
    'カ': 'ka',
    'キ': 'ki',
    'ク': 'ku',
    'ケ': 'ke',
    'コ': 'ko',
    'サ': 'sa',
    'シ': 'shi',
    'ス': 'su',
    'セ': 'se',
    'ソ': 'so',
    'タ': 'ta',
    'チ': 'chi',
    'ツ': 'tsu',
    'テ': 'te',
    'ト': 'to',
    'ナ': 'na',
    'ニ': 'ni',
    'ヌ': 'nu',
    'ネ': 'ne',
    'ノ': 'no',
    'ハ': 'ha',
    'ヒ': 'hi',
    'フ': 'fu',
    'ヘ': 'he',
    'ホ': 'ho',
    'マ': 'ma',
    'ミ': 'mi',
    'ム': 'mu',
    'メ': 'me',
    'モ': 'mo',
    'ヤ': 'ya',
    'ユ': 'yu',
    'ヨ': 'yo',
    'ラ': 'ra',
    'リ': 'ri',
    'ル': 'ru',
    'レ': 're',
    'ロ': 'ro',
    'ワ': 'wa',
    'ヲ': 'wo',
    'ン': 'n',
    'ガ': 'ga',
    'ギ': 'gi',
    'グ': 'gu',
    'ゲ': 'ge',
    'ゴ': 'go',
    'ザ': 'za',
    'ジ': 'ji',
    'ズ': 'zu',
    'ゼ': 'ze',
    'ゾ': 'zo',
    'ダ': 'da',
    'ヂ': 'ji',
    'ヅ': 'zu',
    'デ': 'de',
    'ド': 'do',
    'バ': 'ba',
    'ビ': 'bi',
    'ブ': 'bu',
    'ベ': 'be',
    'ボ': 'bo',
    'パ': 'pa',
    'ピ': 'pi',
    'プ': 'pu',
    'ペ': 'pe',
    'ポ': 'po',
    'キャ': 'kya',
    'キュ': 'kyu',
    'キョ': 'kyo',
    'シャ': 'sha',
    'シュ': 'shu',
    'ショ': 'sho',
    'チャ': 'cha',
    'チュ': 'chu',
    'チョ': 'cho',
    'ニャ': 'nya',
    'ニュ': 'nyu',
    'ニョ': 'nyo',
    'ヒャ': 'hya',
    'ヒュ': 'hyu',
    'ヒョ': 'hyo',
    'ミャ': 'mya',
    'ミュ': 'myu',
    'ミョ': 'myo',
    'リャ': 'rya',
    'リュ': 'ryu',
    'リョ': 'ryo',
    'ギャ': 'gya',
    'ギュ': 'gyu',
    'ギョ': 'gyo',
    'ジャ': 'ja',
    'ジュ': 'ju',
    'ジョ': 'jo',
    'ビャ': 'bya',
    'ビュ': 'byu',
    'ビョ': 'byo',
    'ピャ': 'pya',
    'ピュ': 'pyu',
    'ピョ': 'pyo'
  };

  static const Map<String, String> HIRAGANA_MAP = {
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
    _nextKana();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void _nextKana() {
    final random = Random();

    setState(() {
      if (_selectedScript == 'Hiragana') {
        _currentKana =
            HIRAGANA_MAP.keys.elementAt(random.nextInt(HIRAGANA_MAP.length));
      } else {
        _currentKana =
            KATAKANA_MAP.keys.elementAt(random.nextInt(KATAKANA_MAP.length));
      }
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
    String? expected;
    if (_selectedScript == 'Hiragana') {
      expected = HIRAGANA_MAP[_currentKana];
    } else {
      expected = KATAKANA_MAP[_currentKana];
    }

    if (expected == transliteration) {
      _showCustomSnackBar('Correct!', Colors.green);
    } else {
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
    return Stack(
      children: [
        Positioned(
          top: 16,
          left: 16,
          child: DropdownButton<String>(
            value: _selectedScript,
            items: <String>['Hiragana', 'Katakana'].map((String value) {
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
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentKana,
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
        )
      ],
    );
  }
}
