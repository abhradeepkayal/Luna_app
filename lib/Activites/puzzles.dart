import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PuzzlesPage extends StatefulWidget {
  const PuzzlesPage({super.key});

  @override
  PuzzlesPageState createState() => PuzzlesPageState();
}

class PuzzlesPageState extends State<PuzzlesPage> {
  late String puzzleImageUrl = "";
  late String hint = "";
  String geminiApiKey = "YOUR_GEMINI_API_KEY"; // Replace with your Gemini API Key

  @override
  void initState() {
    super.initState();
    loadPuzzle();
  }

  Future<void> loadPuzzle() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.gemini.com/puzzle?api_key=$geminiApiKey'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          puzzleImageUrl = data['image_url'] ?? "";
          hint = data['hint'] ?? "No hint available.";
        });
      } else {
        throw Exception('Failed to load puzzle');
      }
    } catch (e) {
      setState(() {
        hint = "Error loading puzzle.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture Puzzle Game'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (puzzleImageUrl.isNotEmpty)
                Image.network(
                  puzzleImageUrl,
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),
              Text(
                'Hint: $hint',
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'OpenDyslexic',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loadPuzzle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'New Puzzle',
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