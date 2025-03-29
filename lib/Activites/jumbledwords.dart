import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JumbledWordsPage extends StatefulWidget {
  const JumbledWordsPage({super.key});

  @override
  JumbledWordsPageState createState() => JumbledWordsPageState();
}

class JumbledWordsPageState extends State<JumbledWordsPage> {
  String currentWord = "";
  String jumbledWord = "";
  bool isCorrect = false;

  final String geminiApiKey = "AIzaSyC8aoDt6_PM5i9_xz7AlHBo720SU_nAHSY"; // Replace this!

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    generateJumbledWord();
  }

  Future<void> generateJumbledWord() async {
    const prompt = '''
Generate a simple jumbled word game. Respond with JSON only, like this:
{
  "word": "apple",
  "jumbled": "pleap"
}
Only use real English words, 4-7 letters long. Don't explain.
''';

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final text = body['candidates'][0]['content']['parts'][0]['text'];
        final jsonMatch = RegExp(r'{[^}]+}').firstMatch(text);
        if (jsonMatch != null) {
          final jsonData = jsonDecode(jsonMatch.group(0)!);
          setState(() {
            currentWord = jsonData['word'];
            jumbledWord = jsonData['jumbled'];
            isCorrect = false;
            _controller.clear();
          });
        } else {
          throw Exception("Failed to parse Gemini response.");
        }
      } else {
        throw Exception('Gemini API error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        jumbledWord = "Error loading word.";
        currentWord = "";
      });
    }
  }

  void checkAnswer(String answer) {
    setState(() {
      isCorrect = answer.trim().toLowerCase() == currentWord.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jumbled Words Game'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Jumbled Word: $jumbledWord',
                style: const TextStyle(
                  fontSize: 30,
                  fontFamily: 'OpenDyslexic',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Answer',
                  hintText: 'Enter your guess',
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onChanged: checkAnswer,
              ),
              const SizedBox(height: 20),
              Text(
                isCorrect ? 'Correct! 🎉' : 'Try Again!',
                style: TextStyle(
                  fontSize: 24,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: generateJumbledWord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Next Word',
                  style: TextStyle(fontFamily: 'AtkinsonHyperlegible'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
