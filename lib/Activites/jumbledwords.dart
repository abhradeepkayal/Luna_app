import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const JumbledWordsApp());
}

class JumbledWordsApp extends StatelessWidget {
  const JumbledWordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Jumbled Words Game",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF2B2B2B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2B2B2B),
          titleTextStyle: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFAF3E0),
          ),
          iconTheme: IconThemeData(color: Color(0xFFFAF3E0)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'OpenDyslexic',
            color: Color(0xFFFAF3E0),
            fontSize: 18,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'OpenDyslexic',
            color: Color(0xFFFAF3E0),
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFAF3E0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3C3C3C),
            textStyle: const TextStyle(
              fontFamily: 'OpenDyslexic',
              fontSize: 18,
            ),
          ),
        ),
      ),
      home: const LevelsPage(),
    );
  }
}

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  late Future<int> _unlockedLevel;

  @override
  void initState() {
    super.initState();
    _unlockedLevel = _getUnlockedLevel();
  }

  Future<int> _getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlocked_level') ?? 1;
  }

  Future<void> _unlockNextLevel(int currentLevel) async {
    final prefs = await SharedPreferences.getInstance();
    int newLevel = currentLevel + 1;
    await prefs.setInt('unlocked_level', newLevel);
    setState(() {});
  }

  void _startGame(int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => JumbledWordsGame(
              level: level,
              onLevelComplete: _unlockNextLevel,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent app bar over the background
      appBar: AppBar(
        title: const Text("Jumbled Words Game"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(color: Color(0xFF2B2B2B)),
        child: FutureBuilder<int>(
          future: _unlockedLevel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            int unlockedLevel = snapshot.data!;
            return Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Welcome, Word Wizard!\n\n"
                  "Rules of the Game:\n"
                  "1. Unscramble the jumbled word.\n"
                  "2. Nail all 10 words in a level to unlock the next epic challenge!\n"
                  "3. Speak, type, or even sing your answer (okay, maybe not sing 😉).\n\n"
                  "Get ready to have your brain tickled and your vocabulary dazzled!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: 30,
                    itemExtent: 120.0, // ~5 levels per screen
                    itemBuilder: (context, index) {
                      int level = index + 1;
                      bool isUnlocked = level <= unlockedLevel;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Card(
                          color: const Color(0xFF3C3C3C),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: Icon(
                              isUnlocked ? Icons.lock_open : Icons.lock,
                              size: 36,
                              color:
                                  isUnlocked
                                      ? const Color(0xFFFAF3E0)
                                      : Colors.redAccent,
                            ),
                            title: Text(
                              "Level $level",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            onTap: isUnlocked ? () => _startGame(level) : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class JumbledWordsGame extends StatefulWidget {
  final int level;
  final Function(int) onLevelComplete;
  const JumbledWordsGame({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<JumbledWordsGame> createState() => _JumbledWordsGameState();
}

class _JumbledWordsGameState extends State<JumbledWordsGame> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _jumbledWord = "";
  String _originalWord = "";
  bool _isListening = false;
  bool _isLoading = true;
  int _wordIndex = 0;
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    _generateWords();
  }

  Future<void> _generateWords() async {
    setState(() => _isLoading = true);
    _words = await AIHelper.getJumbledWords(widget.level);
    _loadNextWord();
  }

  void _loadNextWord() {
    if (_wordIndex >= _words.length) {
      // Level complete: all 10 words are done!
      widget.onLevelComplete(widget.level);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFF3C3C3C),
              title: Text(
                "Level Complete!",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Text(
                "Congratulations! You've unlocked the next level of wordy mastery!",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss dialog
                    Navigator.of(context).pop(); // Return to main page
                  },
                  child: Text(
                    "Awesome!",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFFAF3E0),
                    ),
                  ),
                ),
              ],
            ),
      );
      return;
    }
    setState(() {
      _originalWord = _words[_wordIndex];
      _jumbledWord = _shuffleWord(_originalWord);
      _isLoading = false;
    });
  }

  String _shuffleWord(String word) {
    List<String> characters = word.split('');
    characters.shuffle(Random());
    return characters.join();
  }

  void _checkAnswer() async {
    String userAnswer = _controller.text.trim().toLowerCase();
    if (userAnswer == _originalWord.toLowerCase()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Correct! 🎉")));
      _wordIndex++;
      _loadNextWord();
    } else {
      String hint = await AIHelper.getHint(_originalWord);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Try Again ❌ Hint: $hint")));
    }
    _controller.clear();
  }

  // Speak the jumbled word letter by letter at a slower rate
  void _speakWord() async {
    String letterByLetter = _jumbledWord.split('').join(' ');
    // Set a slower speech rate and select a mature female voice (adjust as available)
    await _flutterTts.setSpeechRate(0.3);
    await _flutterTts.setVoice({"name": "Samantha", "locale": "en-US"});
    await _flutterTts.speak(letterByLetter);
  }

  void _startListening() async {
    if (await _speech.initialize()) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() => _controller.text = result.recognizedWords);
        },
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // Wrap content in a SingleChildScrollView to avoid overflow when the keyboard opens
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: MediaQuery.of(context).size.height - 32,
          decoration: const BoxDecoration(color: Color(0xFF2B2B2B)),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "GUESS THE CORRECT WORD",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    "Jumbled Word: $_jumbledWord",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 28),
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  style: const TextStyle(
                    fontFamily: 'OpenDyslexic',
                    color: Color(0xFFFAF3E0),
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Your Answer",
                    labelStyle: TextStyle(
                      fontFamily: 'OpenDyslexic',
                      color: Color(0xFFFAF3E0),
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFAF3E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFAF3E0)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkAnswer,
                  child: const Text("Check Answer"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _speakWord,
                  child: const Text("Speak Word"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Text(
                    _isListening ? "Stop Listening" : "Start Listening",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Level ${widget.level}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

class AIHelper {
  static Future<List<String>> getJumbledWords(int level) async {
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'models/gemini-2.0-flash-001',
    );
    String prompt;
    if (level >= 1 && level <= 10) {
      prompt =
          "Generate random common easy, single English word, each 4 to 6 letters long, for difficulty level $level. Just a single word. All should be in lowercase. Generate 10 such words one by one each after the user guesses correctly. Don't generate 10 words at once";
    } else if (level >= 11 && level <= 20) {
      prompt =
          "Generate random complex, single English words, more than 6 letters long, for difficulty level $level. Just a single word. All in lowercase.Generate 10 such words one by one each after the user guesses correctly.";
    } else {
      prompt =
          "Generate extremely challenging, almost impossible-to-guess single English words for difficulty level $level. Just a single word. All in lowercase.Generate 10 such words one by one each after the user guesses correctly.";
    }
    final response = await model.generateContent([Content.text(prompt)]);
    List<String> words =
        response.text
            ?.split(",")
            .map((w) => w.trim().replaceAll(RegExp(r'[^a-zA-Z]'), ''))
            .where((w) => w.isNotEmpty)
            .toList() ??
        ["flutter"];
    return words;
  }

  static Future<String> getHint(String word) async {
    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'models/gemini-2.0-flash-001',
      );
      final response = await model.generateContent([
        Content.text("Provide a concise hint for the word $word."),
      ]);
      return response.text?.trim() ??
          "The word starts with ${word[0]} and ends with ${word[word.length - 1]}";
    } catch (e) {
      return "The word starts with ${word[0]} and ends with ${word[word.length - 1]}";
    }
  }
}
